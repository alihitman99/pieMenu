#ifndef PIEMENU_H
#define PIEMENU_H

#include <QObject>
#include <QDebug>

class PieMenu : public QObject
{
    Q_OBJECT
public:
    explicit PieMenu(QObject *parent = nullptr);
    Q_INVOKABLE void absolutePositioinPieMenu(int x, int y);

signals:
    void absolutePosition(int x, int y);
private:
    int mPieX;
    int mPieY;
};

#endif // PIEMENU_H
