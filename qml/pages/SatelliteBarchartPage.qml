import QtQuick 2.0
import Sailfish.Silica 1.0
import QtPositioning 5.2
import QtSensors 5.0
import harbour.gpsinfo 1.0
import "../QChart"   //must init and update the submodule "git submodule update --init"
import "../components"

Page {
    id: satelliteBarchartPage
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    property PositionSource positionSource
    property Compass compass
    property GPSDataSource gpsDataSource
    property bool subPagesPushed: false

    onStatusChanged: {
        if (status == PageStatus.Active && !subPagesPushed) {
            subPagesPushed = true
            pageStack.pushAttached(Qt.resolvedUrl("FirstPage.qml"),
                           { positionSource: satelliteBarchartPage.positionSource,
                               gpsDataSource: satelliteBarchartPage.gpsDataSource,
                               compass: satelliteBarchartPage.compass})
            pageStack.navigateForward(PageStackAction.Immediate)
        }
    }

    PageHeader {
        id: header
        title: qsTr("Satellite signal strengths")
    }

    Item {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

    QChart {
        id: rssiBarChart;
        width: parent.width - 2 * Theme.horizontalPageMargin
        height: satelliteBarchartPage.isPortrait ? width : parent.height - 2 * Theme.horizontalPageMargin
        anchors.centerIn: parent
        chartAnimated: true;
        chartAnimationEasing: Easing.Linear;
        chartAnimationDuration: 2000;
        chartType: Charts.ChartType.BAR
        property variant satellites: status === PageStatus.Inactive ? [] : gpsDataSource.satellites;
        property bool componentLoaded: false
        Component.onCompleted: {
            chartData = {
                labels: [],
                labelsColor: [],
                datasets: [{
                        data: [],
                        fillColor: [],
                        borderWidth: [],
                        borderColor: []
                    }]
            }
            chartOptions = {
                scaleStartValue: 0,
                scaleStepWidth: 5,
                scaleSteps: 10,
                scaleOverride: true,
                scaleFontColor: Theme.secondaryHighlightColor,
                scaleFontSize: Theme.fontSizeSmall,
                scaleFontFamily: Theme.fontFamily,
                scaleLineColor: Theme.rgba(Theme.highlightColor, Theme.highlightBackgroundOpacity),
                scaleLineWidth: Theme.fontSizeTiny / 10.0,
                scaleGridLineColor: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity),
                scaleGridLineWidth: Theme.fontSizeTiny / 10.0
            }
            rssiBarChart.componentLoaded = true
        }

        function getRSSI_Color(rssi)
        {
            return "hsl(" + (rssi < 40 ? rssi : 40) * 3 + ",100%,35%)";
        }

        onSatellitesChanged: {
            if (!rssiBarChart.componentLoaded || pageStack.currentPage !== satelliteBarchartPage)
                return;

            var results = gpsDataSource.satellites;

            if(results.length > 0) {
                // Sort satellites by signal strength
                if(settings.barChartOrder == "signal")
                    results.sort(function(a,b) {return b.signalStrength - a.signalStrength})

                // Clear the chart data
                rssiBarChart.chartData.labels = []
                rssiBarChart.chartData.labelsColor = []
                rssiBarChart.chartData.datasets[0].data = []
                rssiBarChart.chartData.datasets[0].fillColor = []
                rssiBarChart.chartData.datasets[0].borderColor = []
                rssiBarChart.chartData.datasets[0].borderWidth = []
                // Insert the data
                results.forEach(function(barSat) {
                    rssiBarChart.chartData.labels.push(barSat.identifier);                    
                    rssiBarChart.chartData.datasets[0].data.push(barSat.signalStrength);
                    //bar color change is used to show sats inUse
                    rssiBarChart.chartData.datasets[0].fillColor.push(barSat.inUse ? getRSSI_Color(barSat.signalStrength):Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity))
                    
                    rssiBarChart.chartData.labelsColor.push(barSat.inUse ? Theme.HighlightColor: Theme.secondaryHighlightColor );
                    rssiBarChart.chartData.datasets[0].borderWidth.push(Theme.fontSizeTiny / 10.0)
                    rssiBarChart.chartData.datasets[0].borderColor.push(barSat.inUse ? "white" : "transparent");

                });

                // Draw minimum of 5 (10) bars in portrait (landscape)
                var additionalBars = 0
                if(satelliteBarchartPage.isPortrait && results.length < 5)
                    additionalBars = 5 - results.length
                else if(satelliteBarchartPage.isLandscape && results.length < 10)
                    additionalBars = 10 - results.length

                while(additionalBars > 0){
                    rssiBarChart.chartData.labels.push(" ");
                    rssiBarChart.chartData.datasets[0].data.push(0);
                    rssiBarChart.chartData.datasets[0].fillColor.push("transparent");
                    additionalBars--
                }
            }
            rssiBarChart.requestPaint();
        }
    }
    }
    InfoField {
        id: satellitesInfo
        label: qsTr("Satellites in use / view")
        value: gpsDataSource.numberOfUsedSatellites + " / " + gpsDataSource.numberOfVisibleSatellites
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingLarge
        visible: parent.isPortrait
    }
}

