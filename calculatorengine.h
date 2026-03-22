#ifndef CALCULATORENGINE_H
#define CALCULATORENGINE_H

#include <QObject>
#include <QString>
#include <QQmlEngine>  // ← ДОБАВЬ ЭТО!

class CalculatorEngine : public QObject
{
    Q_OBJECT  // ← ОБЯЗАТЕЛЬНО!!!
    QML_ELEMENT  // ← ДОБАВЬ ЭТО для Qt 6!

    Q_PROPERTY(QString display READ display WRITE setDisplay NOTIFY displayChanged)
    Q_PROPERTY(QString result READ result NOTIFY resultChanged)

public:
    explicit CalculatorEngine(QObject *parent = nullptr);

    Q_INVOKABLE QString display() const;
    Q_INVOKABLE void setDisplay(const QString &display);
    Q_INVOKABLE QString result() const;

public slots:
    Q_INVOKABLE void appendDigit(const QString &digit);
    Q_INVOKABLE void appendOperation(const QString &op);
    Q_INVOKABLE void calculate();
    Q_INVOKABLE void clear();
    Q_INVOKABLE void clearAll();
    Q_INVOKABLE void toggleSign();
    Q_INVOKABLE void percent();

signals:
    void displayChanged();
    void resultChanged();

private:
    QString m_display = "0";
    QString m_result = "0";
    QString m_pendingOperator;
    QString m_operand1;
};

#endif // CALCULATORENGINE_H
//sd
