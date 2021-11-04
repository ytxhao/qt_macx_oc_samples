#ifndef PLAYSCENE_H
#define PLAYSCENE_H

#include <QMainWindow>
#include "sgcoin.h"

class PlayScene : public QMainWindow
{
    Q_OBJECT
public:
//    explicit PlayScene(QWidget *parent = nullptr);
    PlayScene(int levelNum);

    int levelIndex;

    void paintEvent(QPaintEvent *) override;

    int gameArray[4][4];
    SGCoin *coinBtn[4][4];
    bool isWin;
signals:
    //自定义信号
    void chooseSceneBack();
};

#endif // PLAYSCENE_H
