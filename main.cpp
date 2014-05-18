#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>

#include "VideoProbe.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    qmlRegisterType<VideoProbe>("HudsonPiratePride.Trebuchet", 1, 0, "VideoProbe");

    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));

    if(engine.rootObjects().count() == 0) {
        // nothing loaded, don't launch a zombie process.
        return -1;
    }

    return app.exec();
}
