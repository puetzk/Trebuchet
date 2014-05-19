import QtQuick 2.2
import QtMultimedia 5.0


import HudsonPiratePride.Trebuchet 1.0

Item {
    id: marker
    Image {
        id: icon
        source: "icons/marker.png"
        x: -width/2
        y: -height/2
    }

    property VideoSeek video

    property point spacePosition: Qt.point(50,50)
    property double timePosition : -1

    x: video.mapPointFromSource(spacePosition,video.contentRect).x
    y: video.mapPointFromSource(spacePosition,video.contentRect).y

    MouseArea {
        id: draggable
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: icon

        property bool dragging: false

        onReleased: {
            if(mouse.button == Qt.LeftButton) {
                marker.timePosition = video.startPosition
            }
            dragging = false
        }

        onPressed: {
            dragging = true
            if(mouse.button == Qt.RightButton) {
                marker.video.seekFrame(marker.timePosition)
            }
        }

        onPositionChanged: {
            if(dragging) {
                var mousePoint = mapToItem(null, mouse.x, mouse.y)
                var mappedPos = video.mapPointToSource(Qt.point(mousePoint.x, mousePoint.y))
                marker.spacePosition = Qt.point(mappedPos.x, mappedPos.y)
            }
        }
    }

}

