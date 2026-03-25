#include "calculatorengine.h"
#include <QJSEngine>
#include <QRegularExpression>

// ----------------------------------------------------------------------
// Вспомогательная функция для форматирования чисел с удалением лишних нулей
// ----------------------------------------------------------------------
static QString formatNumber(double value)
{
    // Форматируем с 12 знаками после запятой (можно изменить)
    QString str = QString::number(value, 'f', 12);
    // Удаляем все лишние нули в конце и точку, если после неё ничего не осталось
    str.remove(QRegularExpression("\\.?0+$"));
    return str;
}

// ----------------------------------------------------------------------
// Конструктор
// ----------------------------------------------------------------------
CalculatorEngine::CalculatorEngine(QObject *parent) : QObject(parent)
{
    m_formula = "";
    m_result = "";
}

// ----------------------------------------------------------------------
// Геттеры
// ----------------------------------------------------------------------
QString CalculatorEngine::formula() const { return m_formula; }
QString CalculatorEngine::result() const { return m_result; }

// ----------------------------------------------------------------------
// Приватные сеттеры (вызывают сигналы при изменении)
// ----------------------------------------------------------------------
void CalculatorEngine::setFormula(const QString &formula)
{
    if (m_formula == formula) return;
    m_formula = formula;
    emit formulaChanged();
}

void CalculatorEngine::setResult(const QString &result)
{
    if (m_result == result) return;
    m_result = result;
    emit resultChanged();
}

// ----------------------------------------------------------------------
// Добавление символа в формулу (цифра, точка, оператор)
// ----------------------------------------------------------------------
void CalculatorEngine::appendToFormula(const QString &text)
{
    if (m_justCalculated) {
        setFormula("");
        m_justCalculated = false;
    }

    if (m_formula.length() >= 50) return;

    // Цифры
    if (text == "0" || text == "1" || text == "2" || text == "3" || text == "4" ||
        text == "5" || text == "6" || text == "7" || text == "8" || text == "9") {
        setFormula(m_formula + text);
        return;
    }

    // Точка
    if (text == ".") {
        if (canAppendDot()) {
            setFormula(m_formula + text);
        }
        return;
    }

    // Операторы
    if (text == "+" || text == "-" || text == "×" || text == "÷") {
        if (canAppendOperator(text)) {
            setFormula(m_formula + text);
        }
        return;
    }

    // Прочие символы (не должны сюда попадать, но на всякий случай)
    setFormula(m_formula + text);
}

// ----------------------------------------------------------------------
// Очистка формулы и результата
// ----------------------------------------------------------------------
void CalculatorEngine::clearFormula()
{
    setFormula("");
    setResult("");
    m_justCalculated = false;
}

// ----------------------------------------------------------------------
// Вычисление выражения
// ----------------------------------------------------------------------
void CalculatorEngine::calculate()
{
    if (m_formula.isEmpty()) return;

    QJSEngine engine;
    QString jsFormula = m_formula;
    jsFormula.replace("×", "*").replace("÷", "/").replace("−", "-");
    QJSValue result = engine.evaluate(jsFormula);

    if (result.isError() || result.toString() == "Infinity" || result.toString() == "NaN") {
        setResult("Ошибка");
    } else {
        double value = result.toNumber();
        QString res = formatNumber(value);
        setResult(res);
        setFormula(res);
    }
    m_justCalculated = true;
}

// ----------------------------------------------------------------------
// Удаление последнего символа
// ----------------------------------------------------------------------
void CalculatorEngine::deleteLast()
{
    if (!m_formula.isEmpty()) {
        QString newFormula = m_formula;
        newFormula.chop(1);
        setFormula(newFormula);
    }
}

// ----------------------------------------------------------------------
// Добавление скобки: если открытых больше, добавляем закрывающую, иначе открывающую
// ----------------------------------------------------------------------
void CalculatorEngine::appendParenthesis()
{
    int openCount = m_formula.count('(');
    int closeCount = m_formula.count(')');
    QString newFormula = m_formula;
    if (closeCount < openCount) {
        newFormula += ")";
    } else {
        newFormula += "(";
    }
    setFormula(newFormula);
}

// ----------------------------------------------------------------------
// Смена знака последнего числа
// ----------------------------------------------------------------------
void CalculatorEngine::toggleSign()
{
    if (m_formula.isEmpty()) return;

    QRegularExpression re("(-?\\d+(?:\\.\\d+)?)$");
    QRegularExpressionMatch match = re.match(m_formula);
    if (match.hasMatch()) {
        QString number = match.captured(0);
        QString newNumber = number.startsWith('-') ? number.mid(1) : '-' + number;
        QString newFormula = m_formula;
        newFormula.replace(match.capturedStart(0), match.capturedLength(0), newNumber);
        setFormula(newFormula);
    }
}

// ----------------------------------------------------------------------
// Преобразование последнего числа в проценты (деление на 100)
// ----------------------------------------------------------------------
void CalculatorEngine::percent()
{
    if (m_formula.isEmpty()) return;

    QRegularExpression re("(\\d+(?:\\.\\d+)?)$");
    QRegularExpressionMatch match = re.match(m_formula);
    if (match.hasMatch()) {
        double value = match.captured(0).toDouble();
        value /= 100.0;
        QString newFormula = m_formula;
        newFormula.replace(match.capturedStart(0), match.capturedLength(0), formatNumber(value));
        setFormula(newFormula);
    }
}

// ----------------------------------------------------------------------
// Проверка возможности добавления точки
// ----------------------------------------------------------------------
bool CalculatorEngine::canAppendDot() const
{
    if (m_formula.isEmpty()) return false;

    QRegularExpression re("(\\d+(?:\\.\\d+)?)$");
    QRegularExpressionMatch match = re.match(m_formula);
    if (!match.hasMatch()) return false;

    QString lastNumber = match.captured(0);
    return !lastNumber.contains('.');
}

// ----------------------------------------------------------------------
// Проверка возможности добавления оператора (и замена предыдущего оператора при необходимости)
// ----------------------------------------------------------------------
bool CalculatorEngine::canAppendOperator(const QString &op)
{
    if (m_formula.isEmpty()) {
        return (op == "-");
    }

    QChar lastChar = m_formula.back();
    if (lastChar.isDigit() || lastChar == ')') {
        return true;
    }
    if (lastChar == '+' || lastChar == '-' || lastChar == QChar(0x00D7) || lastChar == QChar(0x00F7)) {
        QString newFormula = m_formula;
        newFormula.chop(1);
        setFormula(newFormula + op);
        return false;
    }
    return false;
}