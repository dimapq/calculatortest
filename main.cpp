#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <QDebug>
#include "calculatorengine.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<CalculatorEngine>("CalculatorEngine", 1, 0, "CalculatorEngine");

    QQmlApplicationEngine engine;

    // Точный путь к твоему main.qml!
    const QUrl url(QStringLiteral("file:///C:/Users/user/Documents/calctest/main.qml"));
    qDebug() << "Loading:" << url;

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qDebug() << "Failed to load QML!";
        return -1;
    }

    return app.exec();
}
//sd
