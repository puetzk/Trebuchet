#ifndef VIDEOPROBE_H
#define VIDEOPROBE_H

#include <QVideoProbe>

//http://www.qtcentre.org/threads/57981-Using-QVideoProbe-from-QML

class VideoFrame : public QObject
{
    Q_OBJECT

    Q_PROPERTY(double startTime READ startTimeMs NOTIFY frameChanged)
    Q_PROPERTY(double endTime READ endTimeMs NOTIFY frameChanged)
public:
    double startTimeMs() { return m_frame.startTime() / 1000.0; }
    double endTimeMs() { return m_frame.startTime() / 1000.0; }
    void operator =(const QVideoFrame &frame) { m_frame = frame; emit frameChanged(); }
signals:
    void frameChanged();
private:
    QVideoFrame m_frame;
};

class VideoProbe : public QVideoProbe
{
    Q_OBJECT

    QObject *m_source; Q_PROPERTY(QObject* source READ source WRITE setSource)
    Q_PROPERTY(bool active READ isActive)

public:
    explicit VideoProbe(QObject *parent = 0);

    QObject* source() { return m_source; }
    bool setSource(QObject *);

signals:
    void videoFrameTime(double startTime, double endTime);
    //void videoFrameMetadata(const QVariantMap &data);
    //void videoFrame(VideoFrame *videoFrame);

private slots:
    void emitVideoFrameProbed(const QVideoFrame &frame);
private:
    VideoFrame m_frameWrapper;
};

#endif // VIDEOPROBE_H
