import QtQuick 2.0
import Sailfish.Silica 1.0
import "../services" as Services
import "../models" as Models
import "../components"

Page {
    id: root
    allowedOrientations: Orientation.All

    // Добавляем свойство для управления видимостью панели
    property bool panelVisible: true

    // Сервисы
    Services.OperationService { id: operationService }
    Services.CategoryService {
        id: categoryService
        Component.onCompleted: initialize()
    }

    // Модель категорий
    Models.CategoryModel {
        id: categoryModel
        service: categoryService
        Component.onCompleted: loadCategoriesByType(0)
    }

    // Основной контент
    default property alias pageContent: contentContainer.data

    Rectangle {
        id: contentContainerWrapper
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: bottomPanel.top
        }
        color: "white"

        Item {
            id: contentContainer
            anchors.fill: parent
        }
    }

    SideDrawerComponent {
        id: sideDrawer
    }

    // Нижняя панель
    DockedPanel {
        id: bottomPanel
        width: parent.width
        height: Theme.itemSizeLarge * 1.1
        dock: Dock.Bottom
        open: root.panelVisible // Используем объявленное свойство

        Rectangle {
            anchors.fill: parent
            color: "#24224f"

            Rectangle {
                id: burger
                width: Theme.itemSizeLarge
                height: Theme.itemSizeExtraLarge
                color: "#24224f"
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    bottomMargin: 10
                }

                IconButton {
                    icon.source: "image://theme/icon-m-menu"
                    anchors.centerIn: parent
                    onClicked: sideDrawer.toggle()
                }
            }

            Rectangle {
                id: grah
                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge
                color: "#24224f"
                anchors {
                    left: burger.right
                    top: burger.top
                }

                IconButton {
                    icon.source: "image://theme/icon-m-storage"
                    anchors.centerIn: parent
                    onClicked: console.log("Analytics clicked")
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: Theme.paddingLarge * 2

                Rectangle {
                    id: mainButton
                    width: Theme.itemSizeExtraLarge * 1.5
                    height: Theme.itemSizeExtraLarge * 1.5
                    radius: width / 2
                    color: mouseArea.pressed ? "#1a3a8f" : "#24224f"
                    y: -height / 3

                    Icon {
                        source: "image://theme/icon-m-add"
                        anchors.centerIn: parent
                        width: Theme.iconSizeLarge
                        height: Theme.iconSizeLarge
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: {
                            sideDrawer.close()
                            pageStack.push(Qt.resolvedUrl("OperationPage.qml"), {
                                operationService: operationService,
                                categoryModel: categoryModel,
                                action: 0
                            })
                        }
                    }
                }
            }
        }
    }
}
