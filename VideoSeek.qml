import QtQuick 2.0
import QtMultimedia 5.0
import HudsonPiratePride.Trebuchet 1.0

Rectangle {
    id: video

    function play() { player.play(); }
    function pause() { player.pause(); }
    function stop() { player.stop(); }

    function nextFrame() {
        timer.pauseAt = timer.endTime + 1; /* will pause when onPositionChanged() happens next */
        player.play();
    }

    function prevFrame() {
        seekFrame(startPosition - 1)
    }

    function seekFrame(desiredPosition)
    {
        var rawDesiredPosition = desiredPosition * framerate/30
        //console.debug("seeking from " + position + " to " + desiredPosition)
        seeking = true
        player.play()
        player.seek(rawDesiredPosition - 300)
        timer.pauseAt = rawDesiredPosition
    }

    function seek(desiredPosition) {
        player.seek(desiredPosition * framerate/30)
    }

    function mapPointToSource(pos) {
        return videoOut.mapPointToSource(pos)
    }

    function mapPointFromSource(pos) {
        return videoOut.mapPointToItem(pos)
    }

    signal paused
    signal stopped
    signal playing
    signal error(variant error, string errorString)

    property alias fillMode:        videoOut.fillMode
    property alias orientation:     videoOut.orientation

    property alias contentRect:     videoOut.contentRect
    property alias sourceRect:      videoOut.sourceRect

    property alias playbackState:   player.playbackState
    property alias autoLoad:        player.autoLoad
    property alias bufferProgress:  player.bufferProgress
    property alias error:           player.error
    property alias errorString:     player.errorString
    property alias availability:    player.availability
    property alias hasAudio:        player.hasAudio
    property alias hasVideo:        player.hasVideo
    property alias metaData:        player.metaData
    property alias muted:           player.muted
    property alias seekable:        player.seekable
    property alias source:          player.source
    property alias status:          player.status
    property alias volume:          player.volume

    // not aliased, use our fancy pause-on-frame stuff to autoPause rather than not starting at all
    property bool autoPlay:         false

    // not directly aliasing these, because we want to properly scale the timebase of high-speed (non-30fps) video
    //property alias playbackRate:    player.playbackRate
    readonly property double duration: player.duration * 30/framerate
    property double playbackRate: 1 * 30/framerate
    property int framerate: 30

    // coarse position (provided by player)
    readonly property double position:        player.position * 30/framerate
    // fine position (provided by VideoProbe)
    readonly property double startPosition:   timer.startTime * 30/framerate
    readonly property double endPosition:     timer.endTime * 30/framerate

    property bool seeking: false

    VideoOutput {
        id: videoOut
        source: player

        anchors.fill: parent

        fillMode: VideoOutput.PreserveAspectFit

        MediaPlayer {
            id: player

            onError: video.error(error,errorString)

            playbackRate: video.playbackRate * (video.framerate/30)

            autoPlay: true
            onStatusChanged: {
                if(status == MediaPlayer.Loading && !video.autoPlay) {
                    timer.pauseAt = 0
                }
            }
        }

        VideoProbe {
            id: timer

            source: player

            property double pauseAt: -1

            property double startTime
            property double endTime

            onVideoFrameTime: {
                timer.startTime = startTime
                timer.endTime = endTime
                //console.debug("recieved frame for " + startTime + "-" + endTime + " ms")

                if(pauseAt >= 0 && startTime <= pauseAt && endTime >= pauseAt) {
                    //console.debug("seek to " + pauseAt + " completed by frame " + startTime + "-" + endTime)
                    player.pause()
                    pauseAt = -1;
                    video.seeking = false
                }
            }
            //onVideoFrameMetadata: console.debug(JSON.stringify(data))
        }
    }

    /* used to show a snapshot of the video item while fast-forwarding from a keyframe (to go seek backwards */
    ShaderEffectSource {
        anchors.fill: videoOut
        id: placeholder
        visible: video.seeking
        live: false
        sourceItem: videoOut
        hideSource: visible

        // give the videoPlaceholder a chance to take a new screenshot,
        // in case the user wants to step backward
        Component.onCompleted: player.paused.connect(scheduleUpdate)
        /*
        states: State {
            name: "seek"
            when: videoPlaceholder.visible

            PropertyChanges {
                target: videoSource
                playbackRate: 2
            }
        }
        */
    }
}
