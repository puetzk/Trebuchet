import QtQuick 2.2
import QtQuick.Window 2.1
import QtMultimedia 5.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1

import HudsonPiratePride.Trebuchet 1.0

Window {
    visible: true
    width: 360
    height: 360

    //MouseArea {
    //    anchors.fill: parent
    //    onClicked: {
    //        //Qt.quit();
    //    }
    //}

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: column.left
        anchors.bottom: parent.bottom


        VideoSeek {
            id: video
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: playback.top

            framerate: 240
            playbackRate: 0.125

            autoPlay: false

            onError: {
               if (MediaPlayer.NoError != error) {
                   console.log("[qmlvideo] VideoItem.onError error " + error + " errorString " + errorString)
               }
            }

            source: "c:/Users/puetzk/Desktop/MVI_0190.MOV"
            muted: true

            DropArea {
                anchors.fill: video
                onDropped: {
                    video.source = drop.urls[0];
                }
            }

            MouseArea {
                anchors.fill: parent
                //onClicked: video.play()
                onWheel: {
                    if(wheel.angleDelta.y > 0) video.nextFrame()
                    if(wheel.angleDelta.y < 0) video.prevFrame()
                }
            }
        }

        Measure {
            id: measure
            anchors.fill: video
            vertex: vertexMarker.spacePosition
            base: baseMarker.spacePosition
            measure: measureMarker.spacePosition

            contentRect: video.contentRect
            sourceRect: video.sourceRect

            angleVisible: angleWanted.checked

            VideoMarker {
                id: vertexMarker
                video: video
                spacePosition: Qt.point(100,100)
            }

            VideoMarker {
                id: baseMarker
                video: video
                spacePosition: Qt.point(150,100)
                visible: angleWanted.checked
            }

            VideoMarker {
                id: measureMarker
                video: video
                spacePosition: Qt.point(150,50)
            }
        }

        Measure {
            id: calibrate
            anchors.fill: video
            vertex: calibrateA.spacePosition
            measure: calibrateB.spacePosition

            contentRect: video.contentRect
            sourceRect: video.sourceRect

            angleVisible: false

            VideoMarker {
                id: calibrateA
                video: video
                spacePosition: Qt.point(50,150)
            }

            VideoMarker {
                id: calibrateB
                video: video
                spacePosition: Qt.point(150,150)
            }
        }

        RowLayout {
            id: playback
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            ImageButton {
                id: prevFrame
                iconSource: "icons/previous.png"
                onClicked: video.prevFrame()
            }

            ImageButton {
                id: play
                iconSource: "icons/" + (video.playbackState ==  MediaPlayer.PlayingState ? "pause.png" : "play.png")
                onClicked: {
                    if(video.playbackState == MediaPlayer.PlayingState) {
                        video.pause()
                    } else {
                        video.play()
                    }
                }
            }

            ImageButton {
                id: nextFrame
                iconSource: "icons/next.png"
                onClicked: video.nextFrame()
            }

            Slider {
                id: progress
                minimumValue: 0
                maximumValue: video.duration
                value: video.position
                height: 20
                Layout.fillWidth: true

                onPressedChanged: if(pressed) video.pause()

                onValueChanged: {
                    if(video.playbackState == MediaPlayer.PausedState) {
                        video.seek(value)
                    }
                }
            }
        }
    }

    Column {
        id: column
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 200

        Row {
            CheckBox {
                id: angleWanted
                text: "Angle:"
            }

            Text{
                id: angleMeasure
                property double value: (measure.angle * 180 / Math.PI)
                property string units: "deg"
                text: (measure.angle * 180 / Math.PI).toFixed(1) + " " + units
                visible: angleWanted.checked
            }

            Text {
                text: " (" + (angleMeasure.value / ((measureMarker.timePosition - baseMarker.timePosition)/1000)).toFixed(1) + "/s)"
                visible: angleWanted.checked && (measureMarker.timePosition != baseMarker.timePosition)
            }
        }


        Row {
            Text {
                id: lengthMeasure
                property double value: measure.length * (calibrateLength.value / calibrate.length)
                property string units: calibrateUnits.text
                text: "Length: " + value.toFixed(1) + " " + units
            }

            Text {
                text: " (" + (lengthMeasure.value / ((measureMarker.timePosition - vertexMarker.timePosition)/1000)).toFixed(1) + "/s)"
                visible: measureMarker.timePosition != vertexMarker.timePosition
            }
        }

        Row {
            Text {
                id: calibrateMeasure
                text: "Calibrate: "
            }
            TextInput {
                focus: true
                id: calibrateLength
                text: "8"
                property double value: parseFloat(text)

                validator: DoubleValidator { bottom:0; }
            }
            Text {
                text: " "
            }

            TextInput {
                id: calibrateUnits
                text: "ft"
            }

        }
    }




}
