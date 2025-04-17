/*
  В основе лежит BasePage.qml: здесь находится всё внутреннее содержимое
  (т.е. за исключением бургера-компонента и подвала в BasePage)
*/
import QtQuick 2.0
import Sailfish.Silica 1.0

BasePage {

    // По умолчанию выбраны "Расходы"
    property string selectedTab: "expenses"

    // header-контейнер
    Rectangle {
        id: header
        width: parent.width
        height: parent.height / 7
        color: "#191546"

        // Верхняя часть с балансом и иконкой
        Row {
            id: balanceRow

            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: Theme.paddingMedium
            }
            spacing: Theme.paddingMedium

            Image {
                source: "../icons/budgetIcon.svg"
                height: Theme.iconSizeLarge
                width: Theme.iconSizeLarge
            }

            Label {
                text: "Баланс"
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraLarge*2
                anchors.verticalCenter: parent.verticalCenter*2
            }
        }

        // Нижняя часть с внутренним переключателем доходы/расходы -
        // можно через валидацию, но тут мало места занимает
        Row {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: Theme.paddingLarge
            }
            spacing: Theme.paddingLarge * 3

            Label {
                text: "Расходы"
                color: selectedTab === "expenses" ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeLarge*1.25
                font.bold: selectedTab === "expenses"

                MouseArea {
                    anchors.fill: parent
                    onClicked: selectedTab = "expenses"
                }
            }

            Label {
                text: "Доходы"
                color: selectedTab === "revenue" ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeLarge*1.25
                font.bold: selectedTab === "revenue"

                MouseArea {
                    anchors.fill: parent
                    onClicked: selectedTab = "revenue"
                }
            }
        }
    }
}
