import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../models" as Models

BasePage {
    id: mainpage
    objectName: "MainPage"

    property string selectedTab: "expenses"
    property int action: 0
    property var categoryModel: Models.CategoryModel {}

    Models.OperationModel {
            id: operationModel
    }

    Models.CategoryModel {
        id: categoryModel
        Component.onCompleted: {
            loadAllCategories();
        }
    }

    Component.onCompleted: {
        operationModel.loadByTypeOperation(selectedTab === "expenses" ? 0 : 1);
    }

    HeaderComponent {
        id: header
        headerText: "Баланс"
        selectedTab: mainpage.selectedTab
        operationModel: operationModel
        onSelectedTabChanged: {
                mainpage.selectedTab = header.selectedTab;
                action: header.selectedTab === "expenses" ? 0 : 1;
                operationModel.loadByTypeOperation(selectedTab === "expenses" ? 0 : 1);
       }
    }

    SilicaListView {
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: Theme.paddingMedium
            }
            model: operationModel
            spacing: Theme.paddingSmall
            clip: true

            delegate: ListItem {
                width: parent.width
                contentHeight: Theme.itemSizeMedium

                property var categoryData: categoryModel.getCategoryById(model.categoryId);

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.paddingMedium
                    color: Theme.rgba("#24224f", 0.9)

                    Row {
                        anchors.fill: parent
                        anchors.margins: Theme.paddingMedium
                        spacing: Theme.paddingMedium

                        Image {
                            id:icon
                            asynchronous: true
                            width: Theme.iconSizeMedium
                            height: width
                            anchors.verticalCenter: parent.verticalCenter
                            source: categoryData ? categoryData.pathToIcon : ""
                            sourceSize: Qt.size(width, height)
                            fillMode: Image.PreserveAspectFit
                        }

                        Column {
                            width: parent.width * 0.6
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: icon.right
                            anchors.leftMargin: Theme.paddingLarge
                            spacing: Theme.paddingSmall

                            Label {
                                text: categoryData ? categoryData.nameCategory : "Без категории"
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeLarge
                                truncationMode: TruncationMode.Fade
                            }
                        }

                        Label {
                            id: amountLabel
                            width: Math.min(implicitWidth, parent.width * 0.35)
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: Theme.paddingSmall
                            }
                            horizontalAlignment: Text.AlignRight
                            text: isNaN(model.total) ? "0 ₽" : Number(model.total).toLocaleString(Qt.locale(), 'f', 2) + " ₽"
                            color: selectedTab === "expenses" ? "red" : "green"
                            font {
                                pixelSize: Theme.fontSizeLarge
                                family: Theme.fontFamilyHeading
                                bold: true
                            }
                            elide: Text.ElideRight
                        }
                    }
                }
                onClicked: {
                        pageStack.push(Qt.resolvedUrl("../pages/CategoryDetailsPage.qml"), {
                            categoryId: model.categoryId,
                            action: mainpage.action,
                            categoryModel: categoryModel
                        });
                }
            }

            VerticalScrollDecorator {}
        }
}
