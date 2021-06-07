import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: aboutPage

    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    onStatusChanged: {
        if(status === PageStatus.Active)
            pageStack.pushAttached(Qt.resolvedUrl("LicensePage.qml"))
    }

    SilicaFlickable {
        id: aboutFlickable
        anchors.fill: parent
        contentHeight: header.height + column.height

        PageHeader {
            id: header
            title: qsTr("View license")
        }

        Column {
            id: column
            anchors {
                top: header.bottom
                horizontalCenter: parent.horizontalCenter
            }
            width: Math.min(Screen.width, aboutFlickable.width)
            spacing: Theme.paddingLarge

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: Qt.resolvedUrl("/usr/share/icons/hicolor/256x256/apps/harbour-gpsinfo.png")
                width: Theme.iconSizeExtraLarge
                height: Theme.iconSizeExtraLarge
                smooth: true
                asynchronous: true
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                text: "GPSInfo"
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.primaryColor
                text: qsTr("An app to show all position information")
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: qsTr("Version") + " 0.13.3-1"  //Must edit both AboutPage.qml and  harbour-gpsinfo.yaml
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: "Copyright © 2014-2016 Marcel Witte\n2019 Miklós Márton\n2019 Matti Lehtimäki\n2019-2020 Matti Viljanen"
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: "English: Marcel Witte\n"+
                      "Deutsch: Marcel Witte\n"+
                      "Español: ???\n"+
                      "Suomi: specig, Tenho, direc85\n"+
                      "Français: ???\n"+
                      "Nederlands: ???\n"+
                      "Magyar: Márton Miklós\n"+
                      "Polski: atlochowski\n"+
                      "Pусский: ???\n"+
                      "Slovenčina: okruhliak\n"+
                      "Svenska: Åke Engelbrektson\n"+
                      "简体中文: dashinfantry"
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: qsTr("GPSInfo is open source software licensed under the terms of the GNU General Public License.")
            }

            AboutLabel {
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                text: qsTr("For suggestions, bugs and ideas visit ")
            }

            Button {
                text: "GitHub"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: Qt.openUrlExternally("https://github.com/direc85/harbour-gpsinfo")
            }

            Item {
                width: parent.width
                height: Theme.paddingMedium
            }
        }
    }
}
