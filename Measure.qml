import QtQuick 2.0

Canvas {
    id: canvas
    property point vertex
    property point base
    property point measure

    property vector2d baseVector: Qt.vector2d(base.x - vertex.x, base.y - vertex.y)
    property vector2d measureVector: Qt.vector2d(measure.x - vertex.x, measure.y - vertex.y)
    readonly property vector2d originVector: Qt.vector2d(1,0)

    property double angleRadius: 50
    property double arrowHeadSize: 10
    property bool angleVisible: true

    //canvasSize: Qt.size(width,height)
    //canvasWindow: Qt.rect(0,0,width, height)


    width: 1000
    height: 1000


    function angleFrom(a,b) {
        function crossProduct(a,b) {
            return a.x*b.y - b.x *a.y
        }
        var angle = Math.atan2(crossProduct(a,b), a.dotProduct(b))
        if(angle < 0) angle = angle + 2 * Math.PI
        return angle;
    }

    // gives 0-180, switches sides
    //property double angle : Math.acos(measureVector.normalized().dotProduct(baseVector.normalized()))
    property double angle: angleFrom(measureVector, baseVector)
    // gives -180-180
    property double length: measureVector.length()

    onVertexChanged: requestPaint()
    onBaseChanged: requestPaint()
    onMeasureChanged: requestPaint()
    onAngleRadiusChanged: requestPaint()
    onArrowHeadSizeChanged: requestPaint()
    onAngleVisibleChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        function arrowHead(x, y, size, angle) {
            ctx.save()
            ctx.translate(x,y)
            ctx.rotate(angle)
            ctx.beginPath()
            ctx.moveTo(0,0)
            ctx.lineTo(-size, size/2)
            ctx.lineTo(-size, -size/2)
            ctx.closePath()
            ctx.restore()
            ctx.fill()
        }

        var ctx = canvas.getContext('2d')
        //ctx.clearRect(0,0,width, height)
        ctx.reset(); // QTBUG-36761, works around resizing problem

        ctx.save()
        ctx.strokeStyle = Qt.rgba(1,1,1,.7)
        ctx.fillStyle = Qt.rgba(1,1,1,.7)
        ctx.lineWidth = 3;
        ctx.lineJoin = "round"

        // draw lines
        ctx.beginPath()
        ctx.moveTo(measure.x, measure.y)
        ctx.lineTo(vertex.x, vertex.y)
        if(angleVisible) {
            ctx.lineTo(base.x, base.y)
        }
        ctx.stroke()

        var measureAngle = angleFrom(originVector,measureVector)

        if(arrowHeadSize > 0) {
            arrowHead(measure.x, measure.y, arrowHeadSize, measureAngle)
        }


        if(angleVisible) {
            // draw arc

            ctx.beginPath()
            ctx.moveTo(vertex.x, vertex.y)
            var baseAngle = angleFrom(originVector, baseVector)

            var radius = Math.min(angleRadius,measureVector.length(), baseVector.length())
            ctx.arc(vertex.x, vertex.y, radius, measureAngle, baseAngle)
            ctx.stroke()

            // draw arrowHead
            if(arrowHeadSize > 0) {
                var head = measureVector.times(radius / measureVector.length())
                // change the angle of the arrowhead by its fraction of the circumference, so it looks balanced
                var angleTweak = arrowHeadSize / (2*Math.PI*radius)
                arrowHead(vertex.x + head.x, vertex.y + head.y, arrowHeadSize, measureAngle - Math.PI/2 + Math.PI*angleTweak)
            }
        }

        ctx.restore()
    }
}
