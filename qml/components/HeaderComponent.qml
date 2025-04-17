/*
  Компонент заголовка для повторного использования на разных страницах
*/
import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: headerRoot
    width: parent.width
    height: parent.height / 7
    color: "#24224f"

    property string headerText: ""
    property int fontSize: Theme.fontSizeExtraLarge*2
    property bool showIcon: true
    property string selectedTab: "expenses"

    // Верхняя часть с текстом и иконкой
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
            visible: headerRoot.showIcon
        }

        Label {
            text: headerRoot.headerText
            color: Theme.highlightColor
            font.pixelSize: headerRoot.fontSize
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Нижняя часть с переключателем расходы/доходы
    Row {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: Theme.paddingLarge
        }
        spacing: Theme.paddingLarge * 3

        Label {
            text: "Расходы"
            color: headerRoot.selectedTab === "expenses" ? Theme.highlightColor : Theme.primaryColor
            font.pixelSize: Theme.fontSizeLarge*1.25
            font.bold: headerRoot.selectedTab === "expenses"

            MouseArea {
                anchors.fill: parent
                onClicked: headerRoot.selectedTab = "expenses"
            }
        }

        Label {
            text: "Доходы"
            color: headerRoot.selectedTab === "revenue" ? Theme.highlightColor : Theme.primaryColor
            font.pixelSize: Theme.fontSizeLarge*1.25
            font.bold: headerRoot.selectedTab === "revenue"

            MouseArea {
                anchors.fill: parent
                onClicked: headerRoot.selectedTab = "revenue"
            }
        }
    }
}
