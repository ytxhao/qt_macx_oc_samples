#include "sgpushbutton.h"
#include <QDebug>
#include <QPropertyAnimation>

//SGPushButton::SGPushButton(QWidget *parent) : QPushButton(parent)
//{

//}

SGPushButton::SGPushButton(QString normalImg,QString pressImg) {

    this->normalImgPath = normalImg;
    this->pressImgPath = pressImg;

    QPixmap pix;
    bool ret = pix.load(normalImg);
    if (!ret) {
        qDebug() << "图片加载失败";
    }
    this->setFixedSize(pix.width(),pix.height());
// 设置不规则图片样式
    this->setStyleSheet("QPushButton{border:0px;}");
//    // 设置图标
    this->setIcon(pix);
//    // 设置图标大小
    this->setIconSize(QSize(pix.width(),pix.height()));
}

void SGPushButton::zoom1() {
    QPropertyAnimation *animation = new QPropertyAnimation(this, "geometry");
    animation->setDuration(200);

    //
    animation->setStartValue(QRect(this->x(),this->y(),this->width(),this->height()));
    //
    animation->setEndValue(QRect(this->x(),this->y() + 10,this->width(),this->height()));
    // 设置弹跳曲线
    animation->setEasingCurve(QEasingCurve::OutBounce);

    animation->start();
}

void SGPushButton::zoom2() {
    QPropertyAnimation *animation = new QPropertyAnimation(this, "geometry");
    animation->setDuration(200);

    //
    animation->setStartValue(QRect(this->x(),this->y()+10,this->width(),this->height()));
    //
    animation->setEndValue(QRect(this->x(),this->y(),this->width(),this->height()));
    // 设置弹跳曲线
    animation->setEasingCurve(QEasingCurve::OutBounce);

    animation->start();
}

void SGPushButton::mousePressEvent(QMouseEvent *e) {
    if (this->pressImgPath != "") {
        QPixmap pix;
        bool ret = pix.load(this->pressImgPath);
        if (!ret) {
            qDebug() << "图片加载失败";
        }
        this->setFixedSize(pix.width(),pix.height());
    // 设置不规则图片样式
        this->setStyleSheet("QPushButton{border:0px;}");
    //    // 设置图标
        this->setIcon(pix);
    //    // 设置图标大小
        this->setIconSize(QSize(pix.width(),pix.height()));
    }

    // 让父类执行其他操作
    return QPushButton::mousePressEvent(e);
}

void SGPushButton::mouseReleaseEvent(QMouseEvent *e) {
    if (this->normalImgPath != "") {
        QPixmap pix;
        bool ret = pix.load(this->normalImgPath);
        if (!ret) {
            qDebug() << "图片加载失败";
        }
        this->setFixedSize(pix.width(),pix.height());
    // 设置不规则图片样式
        this->setStyleSheet("QPushButton{border:0px;}");
    //    // 设置图标
        this->setIcon(pix);
    //    // 设置图标大小
        this->setIconSize(QSize(pix.width(),pix.height()));
    }

    // 让父类执行其他操作
    return QPushButton::mouseReleaseEvent(e);
}
