#include "pieMenu.h"

PieMenu::PieMenu(QObject *parent)
    : QObject{parent}
{}

void PieMenu::absolutePositioinPieMenu(int x, int y)
{
    mPieX = x;
    mPieY = y;

    // qDebug() << x << y;
    emit absolutePosition(mPieX, mPieY);
}
