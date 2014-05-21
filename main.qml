import QtQuick 2.2
import QtQuick.Window 2.1
import QtMultimedia 5.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.1

import HudsonPiratePride.Trebuchet 1.0

Window {
    visible: true
    width: 640
    height: 480

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

        DropArea {
            anchors.fill: video
            onDropped: {
                video.source = drop.urls[0];
            }
        }

        VideoSeek {
            id: video
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: playback.top

            framerate: framerate.value
            playbackRate: playbackRate.ratio

            autoPlay: false

            onError: {
               if (MediaPlayer.NoError != error) {
                   console.log("[qmlvideo] VideoItem.onError error " + error + " errorString " + errorString)
               }
            }

            muted: true

            visible: source != ""

            MouseArea {
                anchors.fill: parent
                //onClicked: video.play()
                onWheel: {
                    if(wheel.angleDelta.y > 0) video.nextFrame()
                    if(wheel.angleDelta.y < 0) video.prevFrame()
                }
            }
        }

        Rectangle {
            anchors.fill: video
            visible: video.source == ""
            Image {
                anchors.top: parent.top
                anchors.bottom: dragPrompt.top
                anchors.left: parent.left
                anchors.right: parent.right
                fillMode: Image.PreserveAspectFit
                source: "icons/Trebuchet.png"
            }

            Text {
                id: dragPrompt

                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                text: "Drag in movie file to begin"
                horizontalAlignment: Text.AlignHCenter
                font.pointSize: 20
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

            visible: video.visible

            color: "salmon"
            opacity: .7

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

            color: "steelblue"
            opacity: .7

            contentRect: video.contentRect
            sourceRect: video.sourceRect

            angleVisible: false

            visible: video.visible

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
        width: 150
        spacing: 5

        property double hangingIndent: 17

        Text {
            text: "Speed: "
            font.bold: true
            font.pointSize: 10
        }

        Row {
            x: column.hangingIndent

            Text {
                text: "Framerate: "
            }

            TextInput {
                id: framerate
                property int value: parseFloat(text)
                text: "240"
                validator: IntValidator { }
            }
        }

        RowLayout {
            //x: column.hangingIndent
            anchors.leftMargin: column.hangingIndent
            anchors.left: parent.left
            anchors.right: parent.right

            Slider {
                id: playbackRate
                Layout.fillWidth: true
                minimumValue: -6
                maximumValue: 3
                stepSize: 1
                value: -3
                property double ratio: Math.pow(2,value)
                property string description: {
                    if(value > 0) return Math.pow(2,value) + "x"
                    if(value < 0) return "1/" + Math.pow(2,-value) + "x";
                    return "1:1"
                }
            }

            Text {
                text: playbackRate.description
            }
        }

        Text {
            text: "Calibrate: "
            font.bold: true
            font.pointSize: 10
            color: calibrate.color
        }

        Row {
            x: column.hangingIndent
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

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            height: timeLabel.height + time.height
            Text {
                id: timeLabel
                text: "Time: "
                font.bold: true
                font.pointSize: 10
                color: calibrate.color
            }


            //anchors.right: parent.right
            Text {
                id: time

                x: column.hangingIndent
                anchors.top: timeLabel.bottom

                text: (video.position - zeroTime) + " ms"
                property double zeroTime: 0
            }
            ImageButton {
                anchors.right: parent.right
                anchors.bottom: time.bottom
                iconSource: "icons/stopwatch.png"
                onClicked: time.zeroTime = video.position
            }
        }

        Text {
            text: "Measure: "
            font.bold: true
            font.pointSize: 10
            color: measure.color
        }


        Row {
            x: column.hangingIndent

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

        Image {
            source: "icons/marker.png"
            width:32
            fillMode: Image.Pad
            Text {
                anchors.top: parent.top
                anchors.left: parent.right
                width: column.width - parent.width
                text: "Drag markers to\nmeasure length/angle"
            }
        }

        Image {
            source: "icons/left-click.png"
            width: 32
            fillMode: Image.PreserveAspectFit

            Text {
                anchors.top: parent.top
                anchors.left: parent.right
                width: column.width - parent.width
                text: "Left-click:\nchange marker's frame"
            }
        }


        Image {
            source: "icons/right-click.png"
            width: 32
            fillMode: Image.PreserveAspectFit

            Text {
                anchors.top: parent.top
                anchors.left: parent.right
                width: column.width - parent.width
                text: "Right-click:\nsee marker's frame"
            }
        }

        Text {
            x:32
            text: "Speed will be shown\nif markers are placed\nat different times"
        }
    }




}
