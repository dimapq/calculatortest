import QtQuick 6.0
import QtQuick.Window 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0

Window {
    id: window
    width: 400
    height: 680
    visible: true
    title: "Calculator"

    property bool longPressActive: false
    property string secretSequence: ""
    property string lastExpression: ""

    Rectangle {
        id: mainRect
        anchors.fill: parent
        color: "#024873"

        Rectangle {
            id: displayRect
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: buttonGrid.top
            anchors.bottomMargin: 20
            color: "#04BFAD"
            radius: 0
            bottomLeftRadius: 16
            bottomRightRadius: 16

            Text {
                id: displayText
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                text: calculator ? (calculator.formula !== "" ? calculator.formula : (calculator.result !== "" ? calculator.result : "0")) : "0"
                font.family: "Open Sans"
                font.pixelSize: 50
                font.letterSpacing: 0.5
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.Wrap
            }

            Text {
                id: historyText
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: displayText.top
                anchors.bottomMargin: 20
                text: lastExpression !== "" ? lastExpression : ""
                font.family: "Open Sans"
                font.pixelSize: 20
                font.letterSpacing: 0.5
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.Wrap
                visible: text !== ""
            }
        }

        GridLayout {
            id: buttonGrid
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            anchors.bottomMargin: 30
            columns: 4
            rowSpacing: 12
            columnSpacing: 12

            Repeater {
                model: [
                    // Первая строка
                    { icon: "qrc:/images/bkt.svg",          action:"parenthesis", isIcon: true, color: "#0889A6" },
                    { icon: "qrc:/images/plus_minus.svg",   action:"toggleSign",  isIcon: true, color: "#0889A6" },
                    { icon: "qrc:/images/percent.svg",      action:"percent",     isIcon: true, color: "#0889A6" },
                    { icon: "qrc:/images/division.svg",     action:"÷",           isIcon: true, color: "#0889A6" },

                    // Вторая строка
                    { text:"7", color:"#B0D1D8", action:"7", isIcon: false },
                    { text:"8", color:"#B0D1D8", action:"8", isIcon: false },
                    { text:"9", color:"#B0D1D8", action:"9", isIcon: false },
                    { icon: "qrc:/images/multiplication.svg", action:"×", isIcon: true, color: "#0889A6" },

                    // Третья строка
                    { text:"4", color:"#B0D1D8", action:"4", isIcon: false },
                    { text:"5", color:"#B0D1D8", action:"5", isIcon: false },
                    { text:"6", color:"#B0D1D8", action:"6", isIcon: false },
                    { icon: "qrc:/images/minus.svg",        action:"-",  isIcon: true, color: "#0889A6" },

                    // Четвёртая строка
                    { text:"1", color:"#B0D1D8", action:"1", isIcon: false },
                    { text:"2", color:"#B0D1D8", action:"2", isIcon: false },
                    { text:"3", color:"#B0D1D8", action:"3", isIcon: false },
                    { icon: "qrc:/images/plus.svg",         action:"+",  isIcon: true, color: "#0889A6" },

                    // Пятая строка
                    { text:"C", color:"#F25E5E", action:"clear",   isIcon: false },
                    { text:"0", color:"#B0D1D8", action:"0",      isIcon: false },
                    { text:".", color:"#B0D1D8", action:".",      isIcon: false },
                    { icon: "qrc:/images/equal.svg",        action:"calculate", isEqual: true, isIcon: true, color: "#0889A6" }
                ]

                delegate: Rectangle {
                    id: buttonRect
                    Layout.fillWidth: true
                    Layout.preferredHeight: width   // высота равна ширине
                    radius: width / 2               // круглые кнопки

                    color: {
                        if (modelData.action === "clear" && mouseArea.pressed) {
                            return "#FFFFFF"
                        }
                        if (window.longPressActive && modelData.isEqual === true) {
                            return "#FF4444"
                        }
                        if (mouseArea.pressed) {
                            return "#F7E425"
                        }
                        return modelData.color
                    }
                    border.color: "#aaa"; border.width: 0.5

                    Image {
                        anchors.centerIn: parent
                        source: modelData.isIcon === true ? modelData.icon : ""
                        width: Math.min(parent.width * 0.5, parent.height * 0.5)
                        height: width
                        visible: modelData.isIcon === true
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        anchors.centerIn: parent
                        text: modelData.isIcon === true ? "" : modelData.text
                        font.family: "Open Sans"
                        font.pixelSize: Math.min(parent.width * 0.35, parent.height * 0.35)
                        font.letterSpacing: 1
                        color: {
                            if (modelData.action === "clear" && mouseArea.pressed) return "#024873"
                            return (modelData.action.match(/^[0-9.]$/) !== null) ? "#024873" : "white"
                        }
                        visible: modelData.isIcon !== true
                    }

                    SequentialAnimation on color {
                        running: window.longPressActive && modelData.isEqual === true
                        loops: Animation.Infinite
                        ColorAnimation { to: "#FF4444"; duration: 300 }
                        ColorAnimation { to: "#FF8888"; duration: 300 }
                        ColorAnimation { to: "#FF4444"; duration: 300 }
                        PauseAnimation { duration: 500 }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent

                        onClicked: {
                            if (window.longPressActive) {
                                if (modelData.text === "1" || modelData.text === "2" || modelData.text === "3") {
                                    window.secretSequence += modelData.text
                                    if (window.secretSequence === "123") {
                                        stackView.push(secretPage)
                                        secretTimer.stop()
                                    }
                                } else if (modelData.action === "calculate") {
                                    return
                                } else {
                                    window.longPressActive = false
                                    window.secretSequence = ""
                                    secretTimer.stop()
                                    handleButton(modelData.action)
                                }
                            } else {
                                handleButton(modelData.action)
                            }
                        }

                        onPressAndHold: {
                            if (modelData.action === "calculate") {
                                window.longPressActive = true
                                window.secretSequence = ""
                                secretTimer.restart()
                            }
                        }
                    }
                }
            }
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: mainRect
    }

    Component {
        id: secretPage
        SecretPage { }
    }

    Timer {
        id: secretTimer
        interval: 5000
        onTriggered: {
            window.longPressActive = false
            window.secretSequence = ""
        }
    }

    function handleButton(action) {
        if (!calculator) return

        switch(action) {
        case "0": case "1": case "2": case "3": case "4":
        case "5": case "6": case "7": case "8": case "9":
        case "+": case "-": case "×": case "÷": case ".":
            calculator.appendToFormula(action)
            break
        case "clear":
            calculator.clearFormula()
            lastExpression = ""
            break
        case "calculate":
            var formulaBefore = calculator.formula
            calculator.calculate()
            if (calculator.result && calculator.result !== "Ошибка" && formulaBefore !== "") {
                if (lastExpression !== formulaBefore) {
                    lastExpression = formulaBefore
                }
            }
            break
        case "parenthesis":
            calculator.appendParenthesis()
            break
        case "toggleSign":
            calculator.toggleSign()
            break
        case "percent":
            calculator.percent()
            break
        }
    }
}