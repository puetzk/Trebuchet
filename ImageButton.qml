import QtQuick 2.2
import QtGraphicalEffects 1.0

Rectangle {
    id: button
    signal clicked

    property alias iconSource: icon.source

    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    //color : mouse.pressed ? "red" : "blue"

    Image {
        anchors.centerIn: parent
        id: icon
    }

    GammaAdjust {
        id: glow

        BrightnessContrast {
            id: dim
            source: icon
            anchors.fill: parent
            brightness: -.25
        }

        source: dim
        anchors.fill: icon
        //radius: 3
        gamma: 1.5
        visible: false
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: button.clicked()
    }

    states: State {
        name: "pressed"
        when: mouse.pressed

        /*
        PropertyChanges {
            target: icon
            anchors.topMargin: 1
            anchors.leftMargin: 1
            anchors.rightMargin: -1
            anchors.bottomMargin: -1
        }*/

        PropertyChanges {
            target: glow
            visible: true
        }
    }
}
