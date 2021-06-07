import QtQuick 2.0
import QtPositioning 5.2
import QtSensors 5.0
import harbour.gpsinfo 1.0
import Sailfish.Silica 1.0
import "../LocationFormatter.js" as LocationFormater


Item {
    id: providers
    property alias positionSource: positionSource
    property alias compass: compass
    property alias gpsDataSource: gpsDataSource
    property alias timing: timing
    function toggleActive() {
            if (positionSource.active) {
                console.log("deactivating GPS");
                positionSource.stop();
                gpsDataSource.active = false;
            } else {
                console.log("activating GPS");
                positionSource.start();
                gpsDataSource.active = true;
            }

    }

    PositionSource {
        id: positionSource
        updateInterval: settings.updateInterval
        active: true
        //timestamp seems to be the only way to know gps has a new fix
        position.onTimestampChanged: {
            if (position.coordinate.isValid) {
                timing.setT2FF()
            }
        }
//            onValidChanged: { //not being called except at startup
//                        console.log("d ");
//                        if (isValid) {
//                            timing.setT2FF();
//                        }
//            }

//            onValidityChanged: {//not being called except at startup
//                                    console.log("e ")
//                                    if (position.coordinate.isValid) {
//                                        timing.setT2FF();
//                                    }
//        }
//            position.onLatitudeValidChanged: {
//                console.log("g ")
//            }

    }

    Compass {
        id: compass
        active: true
    }

    GPSDataSource {
        id: gpsDataSource
        updateInterval: settings.updateInterval
        active: true
        Component.onCompleted:{ //as onActiveChanged is not fired at startup
            onActiveChanged(null)
           // console.log("aa "+active)
        }

        onActiveChanged: {
            if (active) {
                timing.start()
            }
           // console.log("a "+active)
        }
        //onNumberOfUsedSatellitesChanged: console.log("ousc")

    }
    Item {
        id: timing
        property date activateGPSTimestamp: new Date()
        property date firstFixTimestamp: new Date()
        property date lastTimestamp: positionSource.position.timestamp //new Date()
        property bool pendingFix : true
        property int secs2FF : 0
        property int secsSincePosition : 0
        Timer { //keep secsXX running when no position updates
              id: timer
              interval: 1100; running: true; repeat: true;
              onTriggered: {
                  //console.log("tick")
                  timing.secsSincePosition = Math.round((new Date() - timing.lastTimestamp)/1000)
                  if (timing.pendingFix) timing.secs2FF = Math.round(-(new Date() - timing.activateGPSTimestamp)/1000);
              }
          }
        function start() {
            firstFixTimestamp = activateGPSTimestamp = new Date()
            lastTimestamp = positionSource.position.timestamp
            pendingFix =true
            secs2FF = 0
            console.log("c "+pendingFix)
        }

        function setT2FF() {
            timer.restart() //stop timer from timing out
//            console.log("b "+lastTimestamp+" "+positionSource.position.timestamp)
            secsSincePosition = Math.round((positionSource.position.timestamp - lastTimestamp)/1000)
//            console.log("bb "+secsSincePosition)
            lastTimestamp = positionSource.position.timestamp
            if (pendingFix) {
                t2secs2FF(positionSource.position.timestamp)  //using actual position time
                pendingFix=false
                Notices.show("GPS Time to First Fix "+secs2FF, Notice.Long)
            }

        }
        function t2secs2FF(T){
            secs2FF = Math.round((T - activateGPSTimestamp)/1000)
        }
        function formatElapsedTime(T) { //print fn for elapsed times
            if (T<=90) return Math.round(T)+ "sec"
            T=T/60;
            if (T<=90) return LocationFormater.roundToDecimal(T,1)+ "min"
            T=T/60;
            return LocationFormater.roundToDecimal(T,1)+ "hr"
        }
        Component.onCompleted: {

        }

        //                {
        //                    var secsSincePosition = (new Date() - positionSource.position.timestamp)/1000
        //                    return ((secsSincePosition > (1 +settings.updateInterval) ) ? "-"+gpsTimes.roundElapsedTime(secsSincePosition)+"  " : " ")
        //                            + (positionSource.position.coordinate.isValid ? Qt.formatTime(positionSource.position.timestamp, "hh:mm:ss") : "-")
        //                }


//        providers.positionSource.onValidChanged: {
//            pendingFix=positionSource.position.coordinate.isValid
        //    secs2FF =(positionSource.position.coordinate.isValid) ? : // && (positionSource.position.timestamp > activateGPSTimestamp)) {
            //                    pendingFix=false
            //                    t2secs2FF(positionSource.position.timestamp)
            //                    //firstFixTimestamp=positionSource.position.timestamp
            //                    //Math.round((firstFixTimestamp - activateGPSTimestamp)/1000)
            //                    Notices.show("GPS Time to First Fix "+secs2FFStr, Notice.Long)
//       }

    }
}
