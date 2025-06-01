import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    objectName: "aboutPage"
    allowedOrientations: Orientation.All

    SilicaFlickable {
        objectName: "flickable"
        anchors.fill: parent
        contentHeight: layout.height + Theme.paddingLarge

        Column {
            id: layout
            objectName: "layout"
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                objectName: "pageHeader"
                title: qsTr("О приложении")
            }

            Label {
                id: descriptionText
                anchors { left: parent.left; right: parent.right; margins: Theme.horizontalPageMargin }
                color: palette.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                text: qsTr(
                    "WebBudget — это приложение для учёта личных финансов.\n\n"
                ) +
                qsTr("Возможности:\n") +
                qsTr("• Ведение расходов и доходов по категориям\n") +
                qsTr("• Просмотр баланса и аналитики\n") +
                qsTr("• Добавление, редактирование и удаление операций\n") +
                qsTr("• Установка лимитов на категории\n") +
                qsTr("• Импорт и экспорт операций в CSV\n") +
                qsTr("• Ведение финансовых целей\n") +
                qsTr("• Регулярные платежи\n") +
                qsTr("• Графики и статистика\n") +
                qsTr("• Поддержка нескольких типов операций\n") +
                qsTr("• Удобный и современный интерфейс")
            }

            SectionHeader {
                objectName: "licenseHeader"
                text: qsTr("Разработчики")
            }

            Label {
                objectName: "licenseText"
                anchors { left: parent.left; right: parent.right; margins: Theme.horizontalPageMargin }
                color: palette.highlightColor
                font.pixelSize: Theme.fontSizeMedium
                textFormat: Text.PlainText
                wrapMode: Text.Wrap
                text: qsTr("Данное приложение разработали студенты группы КС-22-03 Сулимов Александр и Паршинцева Анна")
            }
        }
    }
}
