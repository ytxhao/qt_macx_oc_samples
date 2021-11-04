#ifndef CHOOSELEVELSCENE_H
#define CHOOSELEVELSCENE_H

#include <QMainWindow>
#include <playscene.h>

class ChooseLevelScene : public QMainWindow
{
    Q_OBJECT
public:
    explicit ChooseLevelScene(QWidget *parent = nullptr);

    void paintEvent(QPaintEvent *) override;

    PlayScene *play = NULL;
signals:
    //自定义信号
    void chooseSceneBack();

};

#endif // CHOOSELEVELSCENE_H
