#include "sgcoin.h"
#include <QDebug>

//SGCoin::SGCoin(QWidget *parent) : QPushButton(parent)
//{

//}

SGCoin::SGCoin(QString btnImg) {

    QPixmap pix;
    bool ret = pix.load(btnImg);
    if (!ret) {
        QString str = QString("图片 %1 加载失败").arg(btnImg);
        qDebug()<<str;
        return;
    }
    this->setFixedSize(pix.width(),pix.height());
    this->setStyleSheet("QPushButton{border:0px;}");
    this->setIcon(pix);
    this->setIconSize(QSize(pix.width(),pix.height()));
    time1 = new QTimer(this);
    time2 = new QTimer(this);

    connect(time1,&QTimer::timeout,[=]{
        QPixmap pix;
        QString str = QString(":/resource/Coin000%1.png").arg(this->min++);
        pix.load(str);
        this->setFixedSize(pix.width(),pix.height());
        this->setStyleSheet("QPushButton{border:0px;}");
        this->setIcon(pix);
        this->setIconSize(QSize(pix.width(),pix.height()));

        if (this->min > this->max) {
            this->min = 1;
            isAnimation = false;
            time1->stop();
        }
    });

    connect(time2,&QTimer::timeout,[=]{
        QPixmap pix;
        QString str = QString(":/resource/Coin000%1.png").arg(this->max--);
        pix.load(str);
        this->setFixedSize(pix.width(),pix.height());
        this->setStyleSheet("QPushButton{border:0px;}");
        this->setIcon(pix);
        this->setIconSize(QSize(pix.width(),pix.height()));

        if (this->max < this->min) {
            this->max = 8;
            isAnimation = false;
            time2->stop();
        }
    });
}

void SGCoin::changeFlag() {
    if (this->flag) {
        time1->start(30);
        isAnimation = true;
        this->flag = false;

    } else {
        time2->start(30);
        isAnimation = true;
        this->flag = true;
    }
}

void SGCoin::mousePressEvent(QMouseEvent *e) {

    if (this->isAnimation || this->isWin) {
        return;
    } else {
        QPushButton::mousePressEvent(e);
    }
}
