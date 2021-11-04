#include "playscene.h"
#include <QDebug>
#include <QMenuBar>
#include <QPainter>
#include <QTimer>
#include <QLabel>
#include <QPropertyAnimation>
#include "sgcoin.h"
#include "sgpushbutton.h"
#include "dataconfig.h"

//PlayScene::PlayScene(QWidget *parent) : QMainWindow(parent)
//{

//}

PlayScene::PlayScene(int levelNum) {
    QString str = QString("进入了第 %1 关").arg(levelNum);
    qDebug()<<str;
    this->levelIndex = levelNum;

    this->setFixedSize(320,588);
    this->setWindowFilePath(":/resource/Coin0001.png");
    this->setWindowTitle("翻金币场景");

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

    QLabel *label = new QLabel;
    label->setParent(this);
    QFont font;
    font.setFamily("华文黑体");
    font.setPointSize(20);
    label->setFont(font);
    QString strLevel = QString("Level:%1").arg(this->levelIndex);
//    label->setText(QString::number(this->levelIndex));
    label->setText(strLevel);

    label->setGeometry(QRect(30, this->height() - 50, 120, 50));

    dataConfig config;
    for (int i=0;i<4;i++) {
        for (int j=0;j<4;j++) {
            this->gameArray[i][j] = config.mData[this->levelIndex][i][j];
        }
    }
    //胜利图片显示
    QLabel *winLabel = new QLabel;
    QPixmap tmpPix;
    tmpPix.load(":/resource/LevelCompletedDialogBg.png");
    winLabel->setGeometry(0,0,tmpPix.width(),tmpPix.height());
    winLabel->setPixmap(tmpPix);
    winLabel->setParent(this);
    winLabel->move((this->width() - tmpPix.width())*0.5, -tmpPix.height());
    // 绘制金币背景图案
    for (int i=0;i<4;i++) {
        for (int j=0;j<4;j++) {
//            QLabel *label = new QLabel;
//            label->setGeometry(0,0,50,50);
//            label->setPixmap(QPixmap(":/resource/BoardNode.png"));
//            label->setParent(this);
//            label->move(57+i*50,200+j*50);
            QPixmap pix = QPixmap(":/resource/BoardNode.png");
            QLabel *label = new QLabel;
            label->setGeometry(0,0,pix.width(),pix.height());
            label->setPixmap(pix);
            label->setParent(this);
            label->move(57+i*50,200+j*50);
            QString str;
            if (this->gameArray[i][j] == 1) {
                str = ":/resource/Coin0001.png";
            } else {
                str = ":/resource/Coin0008.png";
            }
            SGCoin *coin = new SGCoin(str);
            coin->setParent(this);
            coin->move(59+i*50,204+j*50);

            coin->posX = i;
            coin->posY = j;
            coin->flag = this->gameArray[i][j];
            this->coinBtn[i][j] = coin;
            connect(coin,&SGCoin::clicked,[=]{
                for (int i=0;i<4 ;i++ ) {
                    for (int j=0;j<4 ;j++ ) {
                        coinBtn[i][j]->isWin = true;
                    }
                }

                coin->changeFlag();
                this->gameArray[i][j] = this->gameArray[i][j] == 0 ? 1 :0;

                QTimer::singleShot(300,this, [=]{
                    if (coin->posX + 1 <= 3) {
                        // 周围的右侧金币翻转的条件
                        coinBtn[coin->posX + 1][coin->posY]->changeFlag();
                        this->gameArray[coin->posX + 1][coin->posY] = this->gameArray[coin->posX + 1][coin->posY] == 0 ? 1 :0;
                    }

                    if (coin->posX - 1 >= 0) {
                        coinBtn[coin->posX - 1][coin->posY]->changeFlag();
                        this->gameArray[coin->posX - 1][coin->posY] = this->gameArray[coin->posX - 1][coin->posY] == 0 ? 1 :0;
                    }

                    if (coin->posY + 1 <= 3) {
                        coinBtn[coin->posX][coin->posY +1]->changeFlag();
                        this->gameArray[coin->posX][coin->posY+1] = this->gameArray[coin->posX][coin->posY+1] == 0 ? 1 :0;
                    }

                    if (coin->posY - 1 >= 0) {
                        coinBtn[coin->posX][coin->posY -1]->changeFlag();
                        this->gameArray[coin->posX][coin->posY-1] = this->gameArray[coin->posX][coin->posY-1] == 0 ? 1 :0;
                    }

                    for (int i=0;i<4 ;i++ ) {
                        for (int j=0;j<4 ;j++ ) {
                            coinBtn[i][j]->isWin = false;
                        }
                    }

                    this->isWin = true;
                    for (int i=0;i<4 ;i++ ) {
                        for (int j=0;j<4 ;j++ ) {
                            if (coinBtn[i][j]->flag == false) {
                                this->isWin = false;
                                break;
                            }
                        }
                    }
                    if (this->isWin) {
                        qDebug()<< "胜利了";
                        for (int i=0;i<4 ;i++ ) {
                            for (int j=0;j<4 ;j++ ) {
                               coinBtn[i][j]->isWin = true;
                            }
                        }

                        //移动胜利的图片
                        QPropertyAnimation *animation = new QPropertyAnimation(winLabel,"geometry");
                        animation->setDuration(1000);
                        // 设置开始位置
                        animation->setStartValue(QRect(winLabel->x(),winLabel->y(),winLabel->width(),winLabel->height()));;
                        // 设置结束位置
                        animation->setEndValue(QRect(winLabel->x(),winLabel->y()+114,winLabel->width(),winLabel->height()));
                        // 设置缓和曲线
                        animation->setEasingCurve(QEasingCurve::OutBounce);
                        animation->start();
                    }
                });

            });
        }
    }
}

void PlayScene::paintEvent(QPaintEvent *) {
    QPainter painter(this);
    QPixmap pix;
    pix.load(":/resource/PlayLevelSceneBg.png");
    painter.drawPixmap(0,0,this->width(),this->height(),pix);

    // 画背景上的图标
    pix.load(":/resource/Title.png");
    pix = pix.scaled(pix.width() *0.5,pix.height() *0.5);
    painter.drawPixmap(10,30,pix.width(),pix.height(),pix);
}
