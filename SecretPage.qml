// SecretPage.qml
import QtQuick 6.0
import QtQuick.Controls 6.0

Rectangle {
    id: root
    color: "#1a1a1a"

    Canvas {
        id: canvas
        anchors.fill: parent
        anchors.bottomMargin: 10

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.font = "40px 'sans-serif'";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";

            var text = "Секретное меню!\ngithub.com/dimapq\n+7(981)813-38-01\nДмитрий Филенков\nхочу у вас работать";
            var lines = text.split("\n");
            var lineCount = lines.length;
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
        font.family: "sans-serif"
        font.weight: Font.DemiBold
        onClicked: stackView.pop()
    }
}