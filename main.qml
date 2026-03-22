import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import CalculatorEngine 1.0

Window {
    id: window
    width: 400
    height: 700
    visible: true
    title: "Calculator"

    // Только ширина фиксирована, высота тянется!
    maximumWidth: 400
    minimumWidth: 400

    property bool secretMode: false
    property string secretSequence: ""
    property bool longPressActive: false

    StackView {
        id: stackView
        anchors.fill: parent

        Rectangle {
            color: "#f1f1f1"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20

                // 1. ДИСПЛЕЙ СВЕРХУ (фиксированная высота)
                Text {
                    id: displayText
                    text: calculator.display
                    font.pixelSize: 50
                    color: "#333"
                    horizontalAlignment: Text.AlignRight
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    Layout.topMargin: 20
                }

                // 2. РАСТЯЖКА (толкает кнопки вниз!)
                Item {
                    Layout.fillHeight: true
                }

                // 3. КНОПКИ ВНИЗУ (фиксированный блок)
                GridLayout {
                    columns: 4
                    rowSpacing: 12
                    columnSpacing: 12
                    Layout.fillWidth: true
                    Layout.preferredHeight: 340

                    Repeater {
                        model: [
                            {text:"C", color:"#ff9500", action:"clear"},
                            {text:"±", color:"#ff9500", action:"toggleSign"},
                            {text:"%", color:"#ff9500", action:"percent"},
                            {text:"÷", color:"#ff9500", action:"÷"},
                            {text:"7", color:"#333", action:"7"},
                            {text:"8", color:"#333", action:"8"},
                            {text:"9", color:"#333", action:"9"},
                            {text:"×", color:"#ff9500", action:"×"},
                            {text:"4", color:"#333", action:"4"},
                            {text:"5", color:"#333", action:"5"},
                            {text:"6", color:"#333", action:"6"},
                            {text:"-", color:"#ff9500", action:"−"},
                            {text:"1", color:"#333", action:"1"},
                            {text:"2", color:"#333", action:"2"},
                            {text:"3", color:"#333", action:"3"},
                            {text:"+", color:"#ff9500", action:"+"},
                            {text:"0", color:"#333", colSpan:2, action:"0"},
                            {text:".", color:"#333", action:"."},
                            {text:"=", color:"#007aff", action:"calculate", isEqual: true}
                        ]
                        delegate: Rectangle {
                            Layout.preferredWidth: 85
                            Layout.preferredHeight: 85
                            Layout.columnSpan: modelData.colSpan || 1
                            radius: 42
                            color: modelData.color
                            border.color: "#aaa"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.text
                                font.pixelSize: 32
                                color: "white"
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (modelData.isEqual && longPressActive) {
                                        // Секретка: проверяем цифры 1,2,3
                                        if (["1","2","3"].indexOf(modelData.action) >= 0) {
                                            secretSequence += modelData.action
                                            if (secretSequence.length > 3)
                                                secretSequence = secretSequence.slice(-3)
                                            if (secretSequence === "123") {
                                                stackView.push(secretPage)
                                                secretMode = true
                                            }
                                        }
                                    } else {
                                        handleButton(modelData.action)
                                    }
                                }
                                onPressAndHold: {
                                    if (modelData.isEqual) {
                                        longPressActive = true
                                        secretTimer.restart()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Component {
            id: secretPage
            Rectangle {
                color: "#1a1a1a"
                Text {
                    anchors.centerIn: parent
                    text: "Секретное меню"
                    font.pixelSize: 40
                    font.bold: true
                    color: "white"
                }
                Button {
                    text: "Назад"
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 50
                    onClicked: stackView.pop()
                }
            }
        }
    }

    Timer {
        id: secretTimer
        interval: 5000
        onTriggered: {
            window.longPressActive = false
            window.secretSequence = ""
        }
    }

    CalculatorEngine {
        id: calculator
    }

    function handleButton(action) {
        switch(action) {
            case "0": case "1": case "2": case "3": case "4":
            case "5": case "6": case "7": case "8": case "9":
                calculator.appendDigit(action); break;
            case "+": case "-": case "×": case "÷": case "−":
                calculator.appendOperation(action === "−" ? "-" : action); break;
            case "calculate": calculator.calculate(); break;
            case "clear": calculator.clear(); break;
            case "toggleSign": calculator.toggleSign(); break;
            case "percent": calculator.percent(); break;
        }
    }
}
//sd
