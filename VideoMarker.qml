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

    property point spacePosition: Qt.point(x,y)
    property double timePosition : -1

    MouseArea {
        id: draggable
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: icon
        drag.target: marker
        //onPressed: Drag.startDrag()
        drag.minimumX: video.contentRect.x
        drag.maximumX: video.contentRect.x + video.contentRect.width
        drag.minimumY: video.contentRect.y
        drag.maximumY: video.contentRect.y + video.contentRect.height
        drag.threshold: 2

        onReleased: {
            if(mouse.button == Qt.LeftButton) {
                marker.timePosition = video.startPosition
            }
        }

        onPressed: {
            if(mouse.button == Qt.RightButton) {
                marker.video.seekFrame(marker.timePosition)
            }
        }
    }

}

