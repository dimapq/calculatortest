#include "calculatorengine.h"
#include <QRegularExpression>

CalculatorEngine::CalculatorEngine(QObject *) {}

QString CalculatorEngine::display() const { return m_display; }
void CalculatorEngine::setDisplay(const QString &display) {
    if (m_display == display) return;
    m_display = display;
    emit displayChanged();
}

QString CalculatorEngine::result() const { return m_result; }

void CalculatorEngine::appendDigit(const QString &digit) {
    if (m_display == "0" || m_display == "-0") {
        m_display = digit;
    } else if (m_display.length() < 25) {  // Ограничение 25 знаков
        m_display += digit;
    }
    emit displayChanged();
}

void CalculatorEngine::appendOperation(const QString &op) {
    m_operand1 = m_display;
    m_pendingOperator = op;
    m_display = "0";
    emit displayChanged();
}

void CalculatorEngine::calculate() {
    double op1 = m_operand1.toDouble();
    double op2 = m_display.toDouble();
    double res = 0.0;

    if (m_pendingOperator == "+") res = op1 + op2;
    else if (m_pendingOperator == "-") res = op1 - op2;
    else if (m_pendingOperator == "×") res = op1 * op2;
    else if (m_pendingOperator == "÷" && op2 != 0) res = op1 / op2;

    m_result = QString::number(res, 'g', 15);
    m_display = m_result;
    emit displayChanged();
    emit resultChanged();
}

void CalculatorEngine::clear() {
    m_display = "0";
    emit displayChanged();
}

void CalculatorEngine::clearAll() {
    m_display = "0";
    m_result = "0";
    m_pendingOperator.clear();
    m_operand1.clear();
    emit displayChanged();
    emit resultChanged();
}

void CalculatorEngine::toggleSign() {
    if (m_display.startsWith('-')) {
        m_display.remove(0, 1);
    } else if (!m_display.isEmpty() && m_display != "0") {
        m_display = "-" + m_display;
    }
    emit displayChanged();
}

void CalculatorEngine::percent() {
    if (!m_display.isEmpty()) {
        double val = m_display.toDouble() / 100.0;
        m_display = QString::number(val, 'g', 15);
        emit displayChanged();
    }
}
//sd
