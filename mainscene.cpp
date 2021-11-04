#include "mainscene.h"
#include "ui_mainscene.h"
#include "QDebug"
#include "QPixmap"
#include <QPainter>
#include "sgpushbutton.h"
#include <QTimer>
#include <QSoundEffect>
//#include <QSound>
#include <QMediaPlayer>
#include "getmicrophone.h"

MainScene::MainScene(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainScene)
{
    int s = isMicrophoneAuthorization([](bool granted){
         qDebug()<<"granted:"<<granted;
    });
    ui->setupUi(this);
    setFixedSize(320,588);
    QString pixmap_url = ":/resource/Coin0001.png";
//    QImage image(pixmap_url);//定义QImage对象，读取图片
//    if(image.isNull()){
//        qDebug()<<"读取图片错误";
//    } else{
//        image.save(pixmap_url,"PNG");
//    }

//    QPixmap pix;
//    setWindowIcon(QIcon(pix.load(pixmap_url));
//    setWindowIcon(QIcon(":/resource/Coin0001.png"));
    setWindowFilePath(":/resource/Coin0001.png");
    setWindowTitle("翻金币主场景");
//    ui->actionQuit->setIcon(QIcon(":/resource/Coin0001.png"));
    connect(ui->actionQuit, &QAction::triggered,[=]{
        this->close();
    });

//    QSoundEffect *startSound = new QSoundEffect(":/resource/TapButtonSound.wav",this);

    SGPushButton *startBtn = new SGPushButton(":/resource/MenuSceneStartButton.png");
//    SGPushButton *startBtn = new SGPushButton(":/resource/Coin0001.png");
    startBtn->setParent(this);
    startBtn->move(this->width() *0.5-startBtn->width()*0.5,this->height()*0.7);

    chooseScene = new ChooseLevelScene;
    //监听选择关卡的返回按钮的信号
    connect(chooseScene, &ChooseLevelScene::chooseSceneBack, this, [=]{
        this->setGeometry(chooseScene->geometry());
        chooseScene->hide();
        this->show();
    });
    connect(startBtn,&SGPushButton::clicked,[=]{
        qDebug()<<"点击了开始";
        startBtn->zoom1();
        startBtn->zoom2();
        // 延时进入选择关卡场景
        QTimer::singleShot(300,this,[=]{
            this->hide();
//            chooseScene->move(this->pos().x(),this->pos().y());
            chooseScene->setGeometry(this->geometry());
            chooseScene->show();

        });
    });

}

void MainScene::paintEvent(QPaintEvent *) {
    QPainter painter(this);
    QPixmap pix;
    pix.load(":/resource/PlayLevelSceneBg.png");
    painter.drawPixmap(0,0,this->width(),this->height(),pix);

    // 画背景上的图标
    pix.load(":/resource/Title.png");
    pix = pix.scaled(pix.width() *0.5,pix.height() *0.5);
    painter.drawPixmap(10,30,pix);
}

MainScene::~MainScene()
{
    delete ui;
}

