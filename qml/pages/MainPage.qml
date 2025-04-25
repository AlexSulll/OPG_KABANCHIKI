import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../models" as Models

BasePage {
    id: mainpage
    objectName: "MainPage"

    property string selectedTab: "expenses"
    property int action: 0
    property bool isExpense: action === 0
    property var categoryModel: Models.CategoryModel {}
    property var sectors: Models.SectorsModel {}

    Models.CategoryModel {
        id: categoryModel
        Component.onCompleted: {
            loadAllCategories();
        }
    }

    Models.SectorsModel {
        id: sectorModel
    }

    Models.OperationModel {
            id: operationModel
    }

    Component.onCompleted: {
        categoryModel.loadAllCategories();
        operationModel.loadByTypeOperation(selectedTab === "expenses" ? 0 : 1);
        operationModel.calculateTotalBalance();
        sectorModel.calculateChartData(operationModel, 0)
    }


    HeaderComponent {
        id: header
        headerText: Number(operationModel.totalBalance).toLocaleString(Qt.locale(), 'f', 2) + " ₽"
        selectedTab: mainpage.selectedTab
        operationModel: operationModel
        onSelectedTabChanged: {
            mainpage.selectedTab = header.selectedTab
            mainpage.action = header.selectedTab === "expenses" ? 0 : 1
            operationModel.loadByTypeOperation(mainpage.action)
            operationModel.calculateTotalBalance()
            analyticsCard.isExpense = mainpage.action === 0
            sectorModel.calculateChartData(operationModel, mainpage.action)
        }
    }

    MainCardComponent {
        id: analyticsCard
        anchors {
            top: header.bottom
            horizontalCenter: parent.horizontalCenter
            margins: Theme.paddingLarge
        }
        sectors: sectorModel.sectors
        totalValue: operationModel.totalBalance
        isExpense: selectedTab === "expenses"
    }

    SilicaListView {
            anchors {
                top: analyticsCard.bottom
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
                        id: itemContainer
                        anchors.fill: parent
                        anchors.margins: Theme.paddingMedium
                        spacing: Theme.paddingMedium
                        layoutDirection: Qt.LeftToRight

                        Image {
                            id: icon
                            width: Theme.iconSizeMedium
                            height: width
                            source: categoryData ? categoryData.pathToIcon : ""
                            sourceSize: Qt.size(width, height)
                            fillMode: Image.PreserveAspectFit
                        }

                         Label {
                            width: parent.width
                            text: categoryData ? categoryData.nameCategory : "Без категории"
                            color: Theme.primaryColor
                            anchors{
                                verticalCenter: itemContainer.verticalCenter
                                left: icon.right
                                leftMargin: Theme.paddingLarge
                            }
                            font.pixelSize: Theme.fontSizeLarge
                            truncationMode: TruncationMode.Fade
                         }

                        Label {
                            id: amountLabel
                            width: parent.width * 0.35 - Theme.paddingMedium
                            horizontalAlignment: Text.AlignRight
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: Theme.paddingSmall
                            }
                            text: isNaN(model.total) ? "0 ₽" : Number(model.total).toLocaleString(Qt.locale(), 'f', 2) + " ₽"
                            color: selectedTab === "expenses" ? "#FF6384" : Theme.highlightColor
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
