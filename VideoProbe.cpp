#include "VideoProbe.h"

#include <QMediaPlayer>

VideoProbe::VideoProbe(QObject *parent)
    : QVideoProbe(parent), m_source(nullptr)
{
    connect(this,&QVideoProbe::videoFrameProbed, this, &VideoProbe::emitVideoFrameProbed);
}

bool VideoProbe::setSource(QObject* sourceObj)
{
    m_source = sourceObj;
    QMediaPlayer *player = qvariant_cast<QMediaPlayer*>(sourceObj->property("mediaObject"));
    //qDebug() << "VideoProbe::setSource() player"<< player;
    return QVideoProbe::setSource(static_cast<QMediaObject*>(player));
}

void VideoProbe::emitVideoFrameProbed(const QVideoFrame &frame)
{
    if(frame.isValid()) {
        emit videoFrameTime(frame.startTime() / 1000, frame.endTime() / 1000);
        //emit videoFrameMetadata(frame.availableMetaData());
    }
//    m_frameWrapper = frame;
//    emit videoFrame(&m_frameWrapper);
}
