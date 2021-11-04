#ifndef SGPUSHBUTTON_H
#define SGPUSHBUTTON_H

#include <QPushButton>

class SGPushButton : public QPushButton
{
    Q_OBJECT
public:
//    explicit SGPushButton(QWidget *parent = nullptr);
    SGPushButton(QString normalImg,QString pressImg = "");

    QString normalImgPath;
    QString pressImgPath;

    void zoom1();
    void zoom2();

    void mousePressEvent(QMouseEvent *e) override;
    void mouseReleaseEvent(QMouseEvent *e) override;
signals:

};

#endif // SGPUSHBUTTON_H
