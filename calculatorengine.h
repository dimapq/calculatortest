#ifndef CALCULATORENGINE_H
#define CALCULATORENGINE_H

#include <QObject>
#include <QString>

// Класс-движок калькулятора, предоставляет логику вычислений и взаимодействует с QML
class CalculatorEngine : public QObject
{
    Q_OBJECT
    // Свойства, доступные из QML
    Q_PROPERTY(QString formula READ formula WRITE setFormula NOTIFY formulaChanged)
    Q_PROPERTY(QString result READ result WRITE setResult NOTIFY resultChanged)

public:
    explicit CalculatorEngine(QObject *parent = nullptr);

    // Методы, вызываемые из QML (инвокабельные)
    Q_INVOKABLE void appendToFormula(const QString &text);   // Добавить символ в формулу
    Q_INVOKABLE void clearFormula();                         // Очистить формулу и результат
    Q_INVOKABLE void calculate();                            // Вычислить текущее выражение
    Q_INVOKABLE void deleteLast();                           // Удалить последний символ
    Q_INVOKABLE void appendParenthesis();                    // Добавить открывающую/закрывающую скобку
    Q_INVOKABLE void toggleSign();                           // Сменить знак последнего числа
    Q_INVOKABLE void percent();                              // Преобразовать последнее число в проценты

    // Геттеры для свойств
    QString formula() const;
    QString result() const;

signals:
    void formulaChanged();   // Сигнал об изменении формулы
    void resultChanged();    // Сигнал об изменении результата

private:
    // Сеттеры (приватные, чтобы контролировать изменения)
    void setFormula(const QString &formula);
    void setResult(const QString &result);

    QString m_formula;        // Текущая формула (выражение)
    QString m_result;         // Результат последнего вычисления
    bool m_justCalculated = false;  // Флаг, указывающий, что сразу после вычисления нужно начинать новое выражение

    // Вспомогательные методы для валидации ввода
    bool canAppendDot() const;           // Можно ли добавить точку в текущий операнд?
    bool canAppendOperator(const QString &op); // Можно ли добавить оператор (с возможной заменой предыдущего)
};

#endif // CALCULATORENGINE_H