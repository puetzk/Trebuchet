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

    property color color: Qt.rgba(1,1,1,.7)

    // transformation rects if
    property rect sourceRect : Qt.rect(0,0, 1,1)
    property rect contentRect : Qt.rect(0,0, 1,1)

    function mapFromContent(point) {
        return Qt.point((point.x - sourceRect.x) * (contentRect.width/sourceRect.width) + contentRect.x,
                        (point.y - sourceRect.y) * (contentRect.height/sourceRect.height) + contentRect.y)

    }
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

    onColorChanged: requestPaint()
    onVertexChanged: requestPaint()
    onBaseChanged: requestPaint()
    onMeasureChanged: requestPaint()
    onAngleRadiusChanged: requestPaint()
    onArrowHeadSizeChanged: requestPaint()
    onAngleVisibleChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onContentRectChanged: requestPaint()
    onSourceRectChanged: requestPaint()

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
            ctx.fill()
            ctx.restore()
        }

        var ctx = canvas.getContext('2d')
        //ctx.clearRect(0,0,width, height)
        ctx.reset(); // QTBUG-36761, works around resizing problem

        ctx.save()
        ctx.strokeStyle = color
        ctx.fillStyle = color
        ctx.lineWidth = 3;
        ctx.lineJoin = "round"

        var itemVertex = mapFromContent(vertex)
        var itemMeasure = mapFromContent(measure)
        var itemBase = mapFromContent(base)

        // draw lines
        ctx.beginPath()
        ctx.moveTo(itemMeasure.x, itemMeasure.y)
        ctx.lineTo(itemVertex.x, itemVertex.y)
        if(angleVisible) {
            ctx.lineTo(itemBase.x, itemBase.y)
        }
        ctx.stroke()

        var measureAngle = angleFrom(originVector,measureVector)

        if(arrowHeadSize > 0) {
            arrowHead(itemMeasure.x, itemMeasure.y, arrowHeadSize, measureAngle)
        }

        if(angleVisible) {
            // draw arc

            ctx.beginPath()
            var radius = Math.min(angleRadius,measureVector.length(), baseVector.length())
            var head = measureVector.times(radius / measureVector.length())
            ctx.moveTo(itemVertex.x + head.x, itemVertex.y + head.y)
            var baseAngle = angleFrom(originVector, baseVector)

            ctx.arc(itemVertex.x, itemVertex.y, radius, measureAngle, baseAngle)
            ctx.stroke()

            // draw arrowHead
            //if(arrowHeadSize > 0) {
                // change the angle of the arrowhead by its fraction of the circumference, so it looks balanced
                var angleTweak = arrowHeadSize / (2*Math.PI*radius)
                arrowHead(itemVertex.x + head.x, itemVertex.y + head.y, arrowHeadSize, measureAngle - Math.PI/2 + Math.PI*angleTweak)
            //}
        }

        ctx.restore()
    }
}
