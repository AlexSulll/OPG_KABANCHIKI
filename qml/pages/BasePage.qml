import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models" as Models
import "../components"

Page {
    id: root
    allowedOrientations: Orientation.All

    property bool panelVisible: true
    property string selectedTab: "expenses"
    property int selectedAction: selectedTab === "revenue" ? 1 : 0

    SideDrawerComponent {
        action: selectedTab === "expenses" ? 0 : 1
    }

    Models.CategoryModel {
        id: categoryModel
        Component.onCompleted: {
            loadAllCategories();
        }
    }

    Models.GoalModel {
        id: goalModel
    }

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

    DockedPanel {
        id: bottomPanel
        width: parent.width
        height: Theme.itemSizeLarge * 1.1
        dock: Dock.Bottom
        open: root.panelVisible

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#24224f" }
                GradientStop { position: 1.0; color: "#1a1a3a" }
            }

            Rectangle {
                id: burger
                width: Theme.itemSizeLarge
                height: Theme.itemSizeExtraLarge
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#24224f" }
                    GradientStop { position: 1.0; color: "#1a1a3a" }
                }
                anchors {
                    left: parent.left
                    bottom: parent.bottom
                    bottomMargin: 10
                }

                IconButton {
                    icon.source: "image://theme/icon-l-menu"
                    anchors.centerIn: parent
                    onClicked: sideDrawer.toggle()
                }
            }

            Rectangle {
                id: grah
                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#24224f" }
                    GradientStop { position: 1.0; color: "#1a1a3a" }
                }
                anchors {
                    left: burger.right
                    top: burger.top
                }

                IconButton {
                    icon.source: "image://theme/icon-l-storage"
                    anchors.centerIn: parent
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("AnalyticsPage.qml"), {
                            operationModel: operationModel,
                            categoryModel: categoryModel,
                            sectorModel: sectorModel
                        })
                    }
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: Theme.paddingLarge * 2
                z: 10

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
                            pageStack.push(Qt.resolvedUrl("CategoryPage.qml"), {
                                categoryModel: categoryModel,
                                operationModel: operationModel,
                                sectorModel: sectorModel,
                                action: root.selectedAction
                            })
                        }
                    }
                }
            }
            Rectangle {
                id: goals
                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#24224f" }
                    GradientStop { position: 1.0; color: "#1a1a3a" }
                }
                anchors {
                    right: others.left
                    top: burger.top
                }

                IconButton {
                    icon.source: "image://theme/icon-l-whereami"
                    anchors.centerIn: parent
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("../pages/GoalsPage.qml"), {
                                  goalModel: goalModel
                        })
                    }
                }
            }
            Rectangle {
                id: others
                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#24224f" }
                    GradientStop { position: 1.0; color: "#1a1a3a" }
                }
                anchors {
                    right: parent.right
                    top: burger.top
                }

                IconButton {
                    icon.source: "image://theme/icon-l-file-apk"
                    anchors.centerIn: parent
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("....qml"), {
                            operationModel: operationModel,
                            categoryModel: categoryModel,
                            action: selectedTab === "expenses" ? 0 : 1,
                            selectedTab: mainpage.selectedTab
                        })
                    }
                }
            }
        }
    }
}
