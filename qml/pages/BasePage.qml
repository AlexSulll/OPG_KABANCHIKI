/*
    Страница с белым фоном и синим "подвалом",
    а также вызов компонента SideDrawerComponent
    *** мб должна хранится не тут, а также в компонентах - но пока тут
*/
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: root
    allowedOrientations: Orientation.All

    backgroundColor: "white"
    property bool panelVisible: true

    // Основной контент страницы (будет заменяться в дочерних)
    default property alias pageContent: contentContainer.children

    // Вот этот элемент
    Item {
        id: contentContainer

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: bottomPanel.top
        }
    }

    // Компонент вызова бургера
    SideDrawerComponent {
        id: sideDrawer
    }

    // Нижняя панель
    DockedPanel {
        id: bottomPanel
        width: parent.width
        height: Theme.itemSizeLarge * 1.1

        dock: Dock.Bottom
        open: root.panelVisible

        // Контейнер для подвала
        Rectangle {
            anchors.fill: parent
            color: "#191546"

            // Контейнер для бургера
            Rectangle {
                id: burger
                width: Theme.itemSizeLarge
                height: Theme.itemSizeExtraLarge
                color: "#191546"

                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    bottomMargin: 10
                }

                IconButton {
                    icon.source: "image://theme/icon-m-menu"
                    anchors.centerIn: parent

                    // Метод в компоненте
                    onClicked: sideDrawer.toggle()
                }
            }

            // Контейнер для просмотра подробной аналитики (не работает)
            Rectangle {
                id: grah
                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge
                color: "#191546"

                anchors {
                    left: burger.right
                    top: burger.top
                    bottomMargin: 10
                }

                IconButton {
                    icon.source: "image://theme/icon-m-storage"
                    anchors.centerIn: parent

                    // Метод, переходящий на страницу (не создана)
                    onClicked: console.log("grah clicked")
                }
            }

            // Решена проблема центрования выходящей кнопки
            Row {
                anchors.centerIn: parent
                spacing: Theme.paddingLarge * 2

                // Контейнер для главной кнопки
                Rectangle {
                    id: mainButton
                    width: Theme.itemSizeExtraLarge * 1.5
                    height: Theme.itemSizeExtraLarge * 1.5
                    radius: width / 2
                    color: mouseArea.pressed ? "#1a3a8f" : "#122554"
                    y: -height / 3

                    Icon {
                        anchors.centerIn: parent
                        source: "image://theme/icon-m-add"
                        width: Theme.iconSizeLarge
                        height: Theme.iconSizeLarge
                    }

                    // У контейнера главной кнопки Rectangle нет onClicked -
                    // обработка касания через MouseArea
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent

                        onClicked: {

                            // Добавлено автоматическое закрытие бургера при условии перехода,
                            // когда его состояние open
                            sideDrawer.close();
                            pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                        }
                    }
                }
            }
        }
    }
}
