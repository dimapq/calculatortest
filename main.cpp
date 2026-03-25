#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "calculatorengine.h"

int main(int argc, char *argv[])
{
    // Создаём приложение
    QGuiApplication app(argc, argv);

    // Движок QML
    QQmlApplicationEngine engine;

    // Создаём экземпляр движка калькулятора
    CalculatorEngine calculator;
    // Регистрируем его в контексте QML под именем "calculator"
    engine.rootContext()->setContextProperty("calculator", &calculator);

    // Загружаем главный QML-файл из ресурсов
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    // Если не удалось загрузить, выходим с ошибкой
    if (engine.rootObjects().isEmpty())
        return -1;

    // Запускаем событийный цикл
    return app.exec();
}