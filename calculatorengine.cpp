#include "calculatorengine.h"
#include <QJSEngine>
#include <QRegularExpression>

static QString formatNumber(double value)
{
    QString str = QString::number(value, 'f', 12);
    str.remove(QRegularExpression("\\.?0+$"));
    return str;
}

CalculatorEngine::CalculatorEngine(QObject *parent) : QObject(parent)
{
    m_formula = "";
    m_result = "";
}

QString CalculatorEngine::formula() const { return m_formula; }
QString CalculatorEngine::result() const { return m_result; }

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

void CalculatorEngine::appendToFormula(const QString &text)
{
    // Если предыдущее действие было вычисление и пользователь вводит оператор,
    // начинаем новое выражение с результата и оператора
    if (m_justCalculated) {
        if (text == "+" || text == "-" || text == "×" || text == "÷") {
            setFormula(m_result + text);
            m_justCalculated = false;
            return;
        } else {
            setFormula("");
            m_justCalculated = false;
        }
    }

    if (m_formula.length() >= 50) return;

    // Цифры
    if (text == "0" || text == "1" || text == "2" || text == "3" || text == "4" ||
        text == "5" || text == "6" || text == "7" || text == "8" || text == "9") {
        if (!m_formula.isEmpty() && m_formula.back() == ')') return;
        setFormula(m_formula + text);
        return;
    }

    // Точка
    if (text == ".") {
        if (!m_formula.isEmpty() && m_formula.back() == ')') return;
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

    setFormula(m_formula + text);
}

void CalculatorEngine::clearFormula()
{
    setFormula("");
    setResult("");
    m_justCalculated = false;
}

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

void CalculatorEngine::deleteLast()
{
    if (!m_formula.isEmpty()) {
        QString newFormula = m_formula;
        newFormula.chop(1);
        setFormula(newFormula);
    }
}

void CalculatorEngine::appendParenthesis()
{
    if (m_justCalculated) {
        setFormula("");
        m_justCalculated = false;
    }

    int openCount = m_formula.count('(');
    int closeCount = m_formula.count(')');

    if (m_formula.isEmpty()) {
        setFormula("(");
        return;
    }

    QChar lastChar = m_formula.back();

    bool canOpen = (lastChar == '+' || lastChar == '-' || lastChar == QChar(0x00D7) || lastChar == QChar(0x00F7) || lastChar == '(');
    bool canClose = (closeCount < openCount && (lastChar.isDigit() || lastChar == ')'));

    if (canOpen && (openCount == closeCount)) {
        setFormula(m_formula + "(");
    } else if (canClose) {
        setFormula(m_formula + ")");
    }
}

void CalculatorEngine::toggleSign()
{
    if (m_justCalculated) {
        setFormula("");
        m_justCalculated = false;
    }

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

void CalculatorEngine::percent()
{
    if (m_justCalculated) {
        setFormula("");
        m_justCalculated = false;
    }

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

bool CalculatorEngine::canAppendDot() const
{
    if (m_formula.isEmpty()) return false;

    QRegularExpression re("(\\d+(?:\\.\\d+)?)$");
    QRegularExpressionMatch match = re.match(m_formula);
    if (!match.hasMatch()) return false;

    QString lastNumber = match.captured(0);
    return !lastNumber.contains('.');
}

bool CalculatorEngine::canAppendOperator(const QString &op)
{
    if (m_formula.isEmpty()) {
        return (op == "-");
    }

    QChar lastChar = m_formula.back();

    if (lastChar == '(') {
        return (op == "-");
    }

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