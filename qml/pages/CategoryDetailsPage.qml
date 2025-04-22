import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../services" as Services
import "../models" as Models

Page {
    id: categorydetailspage
    objectName: "CategoryDetailsPage"

    property var categoryModel
    property int categoryId
    property int action

    Models.OperationModel {
            id: operationModel
    }

    Component.onCompleted: operationModel.loadByTypeCategory(categoryId, action);

    Models.CategoryModel {
        id: categoryModel
        Component.onCompleted: {
            loadAllCategories();
        }
    }

    HeaderCategoryComponent {
        id: header
        headerText: {
            if (categoryModel) {
                var category = categoryModel.getCategoryById(categoryId)
                return category ? category.nameCategory : "Детали категории"
            }
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
                            text: Number(model.amount).toLocaleString(Qt.locale(), 'f', 2) + " ₽"
                            color: model.action === 0 ? "red" : "green"
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
                        pageStack.push(Qt.resolvedUrl("../pages/OperationDetailsPage.qml"), {
                            operationId: model.id,
                            operationModel: operationModel,
                            categoryModel: categoryModel
                        });
                }
            }

            VerticalScrollDecorator {}
        }
}
