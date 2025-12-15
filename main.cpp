#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QApplication>
#include "pieMenu.h"
// #include "cicularMenuModel.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    // CicularMenuModel cicularMenu;
    // cicularMenu.addItem("Alpha", 1, "#99CA53", "./AircraftIcon.png");
    // cicularMenu.addItem("Epsilon", 1, "#99CA53", "");
    // cicularMenu.addItem("Psi", 1, "#99CA53", "");
    // cicularMenu.addItem("ALi", 1, "#99CA53", "");
    // cicularMenu.addItem("Reza", 1, "#99CA53", "");

    // engine.rootContext()->setContextProperty("cicularMenuModel", &cicularMenu);

    PieMenu pieMenu;
    engine.rootContext()->setContextProperty("pieMenu", &pieMenu);


    const QUrl url(QStringLiteral("qrc:/QCharts/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
