#include "mainscene.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    a.setWindowIcon(QIcon(":/resource/Coin0001.png"));
    MainScene w;
    w.show();
    return a.exec();
}
