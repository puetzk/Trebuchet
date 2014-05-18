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

    DropArea {
        anchors.fill: parent
        onDropped: {
            video.source = drop.urls[0];
        }
    }

    VideoSeek {
        id: video
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: column.top

        autoPlay: false

        onError: {
           if (MediaPlayer.NoError != error) {
               console.log("[qmlvideo] VideoItem.onError error " + error + " errorString " + errorString)
           }
        }

        source: "c:/Users/puetzk/Desktop/MVI_0190.MOV"
        muted: true

        MouseArea {
            anchors.fill: parent
            onClicked: video.play()
        }

    }

    Measure {
        id: measure
        anchors.fill: video
        vertex: vertexMarker.spacePosition
        base: baseMarker.spacePosition
        measure: measureMarker.spacePosition

        angleVisible: angleWanted.checked
    }

    VideoMarker {
        id: vertexMarker
        video: video
        x: 100
        y: 100
    }

    VideoMarker {
        id: baseMarker
        video: video
        x: 150
        y: 100
        visible: angleWanted.checked
    }

    VideoMarker {
        id: measureMarker
        video: video
        x: 150
        y: 50
    }

    Column {
        id: column
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        RowLayout {
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

        Row {
            CheckBox {
                id: angleWanted
                text: "Angle:"
            }

            Text{
                text: (measure.angle * 180 / Math.PI).toFixed(1)
                visible: angleWanted.checked
            }
        }


        Text {
            text: "Length: " + measure.length.toFixed(1)
        }

        Text {
            text: "Speed: " + measure.length.toFixed(1) / (measureMarker.timePosition - baseMarker.timePosition)
        }
    }




}
