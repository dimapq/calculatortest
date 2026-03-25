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
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            anchors.bottomMargin: 30
            columns: 4
            rowSpacing: 12
            columnSpacing: 12

            Repeater {
                model: [
                    {text:"()", color:"#0889A6", action:"parenthesis"},
                    {text:"+/-", color:"#0889A6", action:"toggleSign"},
                    {text:"%", color:"#0889A6", action:"percent"},
                    {text:"÷", color:"#0889A6", action:"÷"},

                    {text:"7", color:"#B0D1D8", action:"7"},
                    {text:"8", color:"#B0D1D8", action:"8"},
                    {text:"9", color:"#B0D1D8", action:"9"},
                    {text:"×", color:"#0889A6", action:"×"},

                    {text:"4", color:"#B0D1D8", action:"4"},
                    {text:"5", color:"#B0D1D8", action:"5"},
                    {text:"6", color:"#B0D1D8", action:"6"},
                    {text:"-", color:"#0889A6", action:"-"},

                    {text:"1", color:"#B0D1D8", action:"1"},
                    {text:"2", color:"#B0D1D8", action:"2"},
                    {text:"3", color:"#B0D1D8", action:"3"},
                    {text:"+", color:"#0889A6", action:"+"},

                    {text:"C", color:"#F25E5E", action:"clear"},
                    {text:"0", color:"#B0D1D8", action:"0"},
                    {text:".", color:"#B0D1D8", action:"."},
                    {text:"=", color:"#0889A6", action:"calculate", isEqual: true}
                ]

                delegate: Rectangle {
                    id: buttonRect
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.preferredHeight: 65
                    radius: 42

                    color: {
                        if (modelData.action === "clear" && mouseArea.pressed) {
                            return "#FFFFFF"
                        }
                        if (window.longPressActive && modelData.isEqual) {
                            return "#FF4444"
                        }
                        if (mouseArea.pressed) {
                            return "#F7E425"
                        }
                        return modelData.color
                    }
                    border.color: "#aaa"; border.width: 0.5

                    Text {
                        anchors.centerIn: parent
                        text: modelData.text
                        font.family: "Open Sans"
                        font.weight: Font.DemiBold
                        font.pixelSize: 24

                        font.letterSpacing: 1
                        color: (modelData.action.match(/^[0-9.]$/) !== null) ? "#024873" : "white"
                    }

                    SequentialAnimation on color {
                        running: window.longPressActive && modelData.isEqual
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

    StackView { id: stackView; anchors.fill: parent; initialItem: mainRect }

    Component {
        id: secretPage
        Rectangle {
            color: "#1a1a1a"

            Canvas {
                id: canvas
                anchors.fill: parent
                anchors.bottomMargin: 100   // оставляем место для кнопки "Назад"
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.font = "90px 'Open Sans Semibold'";
                    ctx.textAlign = "center";
                    ctx.textBaseline = "middle";

                    var text = "Секретное меню!\nhttps://github.com/dimapq\n+7(981)813-38-01\nДмитрий Филенков\nхочу у вас работать";
                    var lines = text.split("\n");
                    var lineCount = lines.length;
                    // Равномерно распределяем строки по высоте Canvas
                    var step = height / (lineCount + 1);
                    for (var i = 0; i < lineCount; i++) {
                        var y = step * (i + 1);
                        var x = width / 2;
                        var gradient = ctx.createLinearGradient(x - 300, y - 45, x + 300, y + 45);
                        gradient.addColorStop(0, "#d60303");
                        gradient.addColorStop(1, "#ffc800");
                        ctx.fillStyle = gradient;
                        ctx.fillText(lines[i], x, y);
                    }
                }
            }

            Button {
                text: "Назад"
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 50
                font.family: "Open Sans"
                font.weight: Font.DemiBold
                onClicked: stackView.pop()
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