import QtQuick 2.0
import QtGraphicalEffects 1.0
import Sailfish.Silica 1.0
import QtSensors 5.0
import harbour.gpsinfo 1.0
import "../components"

Page {
    id: satelliteInfoPage

    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    property Compass compass
    property GPSDataSource gpsDataSource
    property bool satelliteBarchartPagePushed: false
    property int declination: settings.magneticDeclination==undefined ? 0:settings.magneticDeclination
    property variant satellites: status === PageStatus.Inactive ? [] : gpsDataSource.satellites;
    property variant sortedSatellites: status === PageStatus.Inactive ? [] : gpsDataSource.satellites.sort(function(a,b) {return (a.inUse ? 1:-1) - (b.inUse ? 1:-1)}) //so we can draw InUse sats on top...

    states: [
        State {
            name: 'landscape';
            when: orientation === Orientation.Landscape || orientation === Orientation.LandscapeInverted;
            AnchorChanges {
                target: radar;
                anchors.horizontalCenter: undefined;
                anchors.left: satelliteInfoPage.left;
            }
            PropertyChanges {
                target: satellitesInfo;
                width: satelliteInfoPage.width / 2;
                anchors.leftMargin: satelliteInfoPage.width / 2.2;
            }
        }
    ]

    property int radarWidth: Screen.width - Theme.paddingLarge
    property int diameter: radarWidth - 2 * Theme.paddingLarge
    property int radius: diameter / 2
    property int center: radarWidth / 2

    SilicaFlickable {
        anchors.fill: parent

    MainMenu {
        id: siMainMenu
        positionSource: providers.positionSource
    }
    PageHeader {
        title: qsTr("Satellite Info")
    }


    // Radar background gradient is symmetrical,
    // so we don't have to waste cycles rotating it.
    RadialGradient {
        id: radarBG
        anchors.centerIn: radar
        width: diameter
        height: diameter
        source: Rectangle {
            width: radarBG.width
            height: width
            radius: width / 2
        }

        horizontalOffset: 0
        horizontalRadius: width / 2
        verticalRadius: width / 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.0, 0.3, 0.0, 0.8) }
            GradientStop { position: 1.0; color: Qt.rgba(0.0, 0.7, 0.0, 0.8) }
        }
    }

    // The same applies to the radar rings, too.
    Repeater {
        model: [ 1, 2 ]
        delegate: Rectangle {
            width: diameter * Math.cos(Math.PI * modelData / 6)
            height: width
            anchors.centerIn: radar
            radius: width / 2
            color: "transparent"
            border.color: "#77ff77"
            border.width: Theme.iconSizeExtraSmall / 10.0
            opacity: 0.5
        }
    }

    // The main radar container item
    Item {
        id: radar
        width: radarWidth
        height: radarWidth
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter; //satelliteInfoPage.horizontalCenter;
        anchors.left: undefined;

        // At least with Jolla Phone, the reading must be negated
        // so that the compass turns in correct direction.

        property int north: !settings.rotate || status === PageStatus.Inactive || compass.reading === null ? 0 : -compass.reading.azimuth - declination;
        rotation: north

        // At least with Sony Xperia XA2, the compass value is updated
        // only a few times a second, resulting in jerkiness and poor user experience.
        // RotationAnimation really saves the day here!
        Behavior on rotation {
            RotationAnimation {
                easing.type: Easing.Linear
                direction: RotationAnimation.Shortest
            }
        }

        // The N-S and W-E lines, rotated by parent
        Repeater {
            model: [ 0, 1 ]
            delegate: Rectangle {
                width: Theme.iconSizeExtraSmall / 10.0
                height: diameter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                rotation: modelData * 90
                color: "#77ff77"
                opacity: 0.5
            }
        }
        //Magnetic N line
            Rectangle {
                        width: Theme.iconSizeExtraSmall / 10.0
                        height: diameter/2
                        anchors.left: parent.horizontalCenter
                        anchors.bottom: parent.verticalCenter  //+diameter/2
                        transform: Rotation { origin.x: 0 ; origin.y: diameter/2; angle: declination}
                        color: "#ff0000"
                        opacity: (declination !=0) ? 1 : 0 //0.5
                    }
        //Movement Direction line
            Rectangle { visible: !isNaN(gpsDataSource.movementDirection)
                        width: Theme.iconSizeExtraSmall / 10.0
                        height: 1.1*diameter/2
                        anchors.left: parent.horizontalCenter
                        anchors.bottom: parent.verticalCenter  //+diameter/2
                        transform: Rotation { origin.x: 0 ; origin.y: 1.1*diameter/2; angle: isNaN(gpsDataSource.movementDirection) ? 170 : gpsDataSource.movementDirection}
                        color: "cyan"
                        opacity: 1
                    }

        // North, East, South, West, MagneticNorth indicators
        Repeater {
            model: declination !=0 ? ["N", "E", "S", "W", "M"]:["N", "E", "S", "W"]

            delegate:
                Label {
                x: center + Math.sin((index !==4 ? (index * 90) : declination) * Math.PI / 180) * (radius+width/2) - width / 2.0
                y: center - Math.cos((index !==4 ? (index * 90) : declination) * Math.PI / 180) * (radius+width/2) - height / 2.0
                color: ["white","white","red"][iN]
                font.weight: Font.Bold
                font.pixelSize: Theme.fontSizeExtraSmall
                property int iN: index !==4 ? 0 : compass.reading.calibrationLevel > 0.99 ?1:2
                text: " "+[modelData,"M","m"][iN]+" "  //index !==4 ? " "+modelData+" " : compass.reading.calibrationLevel > 0.99 ? " M ":" m "


                // Negate the radar containers rotation, so that the boxes and texts
                // stay upright according to device orientation. Note that radar.rotation
                // value read is already smoothed, so we can just use it raw.
                rotation: -radar.rotation

                Rectangle {
                    z: -1
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width + parent.font.pixelSize / 8.0
                    height: parent.height + parent.font.pixelSize / 8.0
                    color: ["blue","red","transparent"][iN] //index !== 4 ? "blue" : "red"
                    radius: parent.font.pixelSize / 8.0
                }
            }
        }
        // Satellite identifiers (numbers), and their respective box rssi color and inUse border
        // first draw them all solid , hiding the radar chart background, and ensuring colors are correct
        Repeater {
            model: status === PageStatus.Inactive ? [] : sortedSatellites
            delegate:
                Label {
                x: center + Math.sin((modelData.azimuth) * Math.PI / 180) * radius * Math.cos(modelData.elevation * Math.PI / 180) - width / 2.0
                y: center - Math.cos((modelData.azimuth) * Math.PI / 180) * radius * Math.cos(modelData.elevation * Math.PI / 180) - height / 2.0
                font.weight: Font.Bold
                font.pixelSize: Theme.fontSizeExtraSmall
                text: " "+modelData.identifier+" "
                color: "white"
                opacity: 1.0

                // Negate the radar containers rotation, so that the boxes and texts
                // stay upright according to device orientation. Note that radar.rotation
                // value read is already smoothed, so we can just use it raw.
                rotation: -radar.rotation

                Rectangle {
                    z: -1
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width + parent.font.pixelSize / 8.0
                    height: parent.height + parent.font.pixelSize / 8.0
                    color:  Qt.hsla(Math.floor(modelData.signalStrength < 40.0 ? modelData.signalStrength-(1.0/modelData.signalStrength) : 40.0) / 120.0, 1.0, 0.35, 1.0)
                    opacity: 1
                    radius: parent.font.pixelSize / 8.0

                    // If the satellite is used for calculating the position,
                    // draw a white border around the background box.
                    border.color: modelData.inUse ? "white" : "transparent"
                    border.width: modelData.inUse ? Theme.iconSizeExtraSmall / 10.0 : 0.0
                }
            }
        }

        // Satellite identifiers (numbers), and their respective box rssi color and inUse border
        //now draw transparent, so that overlaid numbers can be read.
        Repeater {
            //sort active sats on top.
            model: status === PageStatus.Inactive ? [] : sortedSatellites
            delegate:
                Label {
                x: center + Math.sin((modelData.azimuth) * Math.PI / 180) * radius * Math.cos(modelData.elevation * Math.PI / 180) - width / 2.0
                y: center - Math.cos((modelData.azimuth) * Math.PI / 180) * radius * Math.cos(modelData.elevation * Math.PI / 180) - height / 2.0
                font.weight: Font.Bold
                font.pixelSize: Theme.fontSizeExtraSmall
                text: " "+modelData.identifier+" "
                color: "white"

                // Negate the radar containers rotation, so that the boxes and texts
                // stay upright according to device orientation. Note that radar.rotation
                // value read is already smoothed, so we can just use it raw.
                rotation: -radar.rotation

//                Rectangle {
//                    z: -1
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    anchors.verticalCenter: parent.verticalCenter
//                    width: parent.width + parent.font.pixelSize / 8.0
//                    height: parent.height + parent.font.pixelSize / 8.0
//                    color: "transparent" //Qt.hsla(Math.floor(modelData.signalStrength < 40.0 ? modelData.signalStrength-(1.0/modelData.signalStrength) : 40.0) / 120.0, 1.0, 0.35, 1.0)
//                    opacity: 0.5
//                    radius: parent.font.pixelSize / 8.0

//                    // If the satellite is used for calculating the position,
//                    // draw a white border around the background box.
//                    border.color: modelData.inUse ? "white" : "transparent"
//                    border.width: modelData.inUse ? Theme.iconSizeExtraSmall / 10.0 : 0.0
//                }
            }
        }


    }

    InfoField {
        id: satellitesInfo
        label: qsTr("Satellites in use / view")
        value: gpsDataSource.numberOfUsedSatellites + " / " + gpsDataSource.numberOfVisibleSatellites
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingLarge*1.1  //move up a bit for parallax clipping at glass edge
    }
}
}
