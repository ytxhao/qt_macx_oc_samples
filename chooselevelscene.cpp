#include "chooselevelscene.h"
#include <QMenuBar>
#include <QPainter>
#include "sgpushbutton.h"
#include <QDebug>
#include <QTimer>
#include <QLabel>


ChooseLevelScene::ChooseLevelScene(QWidget *parent) : QMainWindow(parent)
{


    this->setFixedSize(320,588);
    this->setWindowFilePath(":/resource/Coin0001.png");
    this->setWindowTitle("选择关卡场景");
    QMenuBar *bar = menuBar();
    bar->setNativeMenuBar(false);
    setMenuBar(bar);
    QMenu *starMenu = bar->addMenu("开始");
    QAction *quitAction = starMenu->addAction("退出");

    connect(quitAction, &QAction::triggered, [=]{
        this->close();
    });


     SGPushButton *backBtn = new SGPushButton(":/resource/BackButton.png", ":/resource/BackButtonSelected.png");

     backBtn->setParent(this);
     backBtn->move(this->width() - backBtn->width(), this->height() - backBtn->height());

     connect(backBtn,&SGPushButton::clicked,[=]{
        qDebug()<<"点击返回";
        QTimer::singleShot(300,this,[=]{
            emit this->chooseSceneBack();
        });
     });

     // 创建选择关卡的按钮
     for (int i=0;i<20;i++) {
        SGPushButton *menuBtn = new SGPushButton(":/resource/LevelIcon.png");
        menuBtn->setParent(this);
        menuBtn->move(25 + i%4 * 70, 130 + i/4 * 70);

        connect(menuBtn, &SGPushButton::clicked,[=]{
            QString str = QString("选择的是第 %1 关").arg(i+1);
            qDebug()<<str;
            this->hide();
            play = new PlayScene(i+1);
//            play->move(this->pos().x(),this->pos().y());
            play->setGeometry(this->geometry());
            play->show();

            connect(play, &PlayScene::chooseSceneBack, [=]{
                this->setGeometry(play->geometry());
                this->show();
                delete play;
                play = NULL;
            });
        });

        QLabel *lable = new QLabel;
        lable->setParent(this);
        lable->setFixedSize(menuBtn->width(), menuBtn->height());
        lable->setText(QString::number(i+1));
        lable->move(25 + i%4 * 70, 130 + i/4 * 70);
        lable->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
        // 设置让鼠标点击事件穿透
        lable->setAttribute(Qt::WA_TransparentForMouseEvents);

     }


}


void ChooseLevelScene::paintEvent(QPaintEvent *) {
    QPainter painter(this);
    QPixmap pix;
    pix.load(":/resource/OtherSceneBg.png");
    painter.drawPixmap(0,0,this->width(),this->height(),pix);


    // 画背景上的图标
    pix.load(":/resource/Title.png");
//    pix = pix.scaled(pix.width() *0.5,pix.height() *0.5);
    painter.drawPixmap((this->width() - pix.width())*0.5,30,pix.width(),pix.height(),pix);
}
