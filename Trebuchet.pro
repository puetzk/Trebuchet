TEMPLATE = app

QT += qml quick multimedia

SOURCES += main.cpp \
    VideoProbe.cpp

RESOURCES += qml.qrc

RC_FILE = Trebuchet.rc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    VideoProbe.h
