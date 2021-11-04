QT       += core gui multimedia

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    audio_unit_recoder.mm \
    chooselevelscene.cpp \
    dataconfig.cpp \
    main.cpp \
    mainscene.cpp \
    mainwindow.cpp \
    playscene.cpp \
    sgcoin.cpp \
    sgpushbutton.cpp

HEADERS += \
    audio_unit_recoder.h \
    chooselevelscene.h \
    dataconfig.h \
    mainscene.h \
    mainwindow.h \
    playscene.h \
    sgcoin.h \
    sgpushbutton.h \
    macro/IMSMacro.h

FORMS += \
    mainscene.ui \
    mainwindow.ui


#objective c
#OBJECTIVE_SOURCES += ocview.mm
#QMAKE_INFO_PLIST += MultiWindow.plist
macx {
#    QMAKE_LFLAGS    += -framework OpenGLES
    QMAKE_LFLAGS    += -framework GLKit
    QMAKE_LFLAGS    += -framework QuartzCore
    QMAKE_LFLAGS    += -framework CoreVideo
    QMAKE_LFLAGS    += -framework CoreAudio
    QMAKE_LFLAGS    += -framework CoreImage
    QMAKE_LFLAGS    += -framework CoreMedia
    QMAKE_LFLAGS    += -framework AVFoundation
    QMAKE_LFLAGS    += -framework AudioToolbox
    QMAKE_LFLAGS    += -framework CoreGraphics
    LIBS += -framework Cocoa
    LIBS += -framework Foundation
#    QMAKE_LFLAGS    += -framework UIKit
    QMAKE_CXXFLAGS  +=  -x objective-c++ -fobjc-arc

    OBJECTIVE_SOURCES += \
    getMicrophone.mm

    OBJECTIVE_HEADERS += \
    getMicrophone.h

    QMAKE_INFO_PLIST += xxinfo.plist

}

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

RESOURCES += \
    res.qrc

DISTFILES += \
    macx/xxinfo.plist
