#ifndef SGCOIN_H
#define SGCOIN_H
#include <QTimer>
#include <QPushButton>

class SGCoin : public QPushButton
{
    Q_OBJECT
public:
//    explicit  SGCoin(QWidget *parent = nullptr);

    SGCoin(QString btnImg);

    void changeFlag();

    int posX;
    int posY;
    bool flag;

    QTimer *time1;
    QTimer *time2;
    int min = 1;
    int max = 8;

    bool isAnimation = false;

    void mousePressEvent(QMouseEvent *e) override;

    bool isWin = false;

signals:

};

#endif // SGCOIN_H
