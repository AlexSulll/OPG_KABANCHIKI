import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"  as Components
import "../models" as Models

BasePage {
    id: mainpage
    objectName: "MainPage"

    property string selectedTab: "expenses"
    property int action: 0
    property bool isExpense: action === 0
    property var categoryModel: Models.CategoryModel {}
    property var sectors: Models.SectorsModel {}

    property string currentPeriod: "month"
    property date startDate
    property date endDate

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
            Component.onCompleted: {
                loadByTypeOperation(selectedTab === "expenses" ? 0 : 1, startDate, endDate)
            }
    }

    Component.onCompleted: {
        var dates = getPeriodDates(currentPeriod);
        startDate = dates.startDate;
        endDate = dates.endDate;

        categoryModel.loadAllCategories()
        operationModel.loadByTypeOperation(selectedTab === "expenses" ? 0 : 1, startDate, endDate)
        operationModel.calculateTotalBalance()
        sectorModel.calculateChartData(operationModel, 0)
        getPeriodDates(currentPeriod)
    }


    Components.HeaderComponent {
        id: header
        headerText: Number(operationModel.totalBalance).toLocaleString(Qt.locale(), 'f', 2) + " ₽"
        selectedTab: mainpage.selectedTab
        operationModel: operationModel
        onSelectedTabChanged: {
            mainpage.selectedTab = header.selectedTab
            mainpage.action = header.selectedTab === "expenses" ? 0 : 1
            operationModel.loadByTypeOperation(mainpage.action, startDate, endDate)
            operationModel.calculateTotalBalance()
            analyticsCard.isExpense = mainpage.action === 0
            sectorModel.calculateChartData(operationModel, mainpage.action, startDate, endDate)
        }
    }

    Row {
        id: periodSelector
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            margins: Theme.paddingMedium
            topMargin: Theme.paddingLarge
        }

        height: Theme.itemSizeMedium
        spacing: Theme.paddingSmall

        Repeater {
            model: ["day", "week", "month", "year", "custom"]

            delegate: Components.PeriodButton {
                width: (periodSelector.width - periodSelector.spacing*4)/5
                period: modelData
                selectedPeriod: mainpage.currentPeriod

                onPeriodSelected: {
                    if(period === "custom") {
                        dateRangeDialog.open()
                    } else {
                        mainpage.currentPeriod = period;
                        var dates = getPeriodDates(period); // Обновляем даты
                        operationModel.loadByTypeOperation(mainpage.action, dates.startDate, dates.endDate);
                        sectorModel.calculateChartData(operationModel, mainpage.action);
                    }
                }
            }
        }
    }

    Components.MainCardComponent {
        id: analyticsCard
        anchors {
            top: periodSelector.bottom
            horizontalCenter: parent.horizontalCenter
            margins: Theme.paddingLarge
        }
        sectors: sectorModel.sectors
        totalValue: operationModel.totalBalance
        isExpense: selectedTab === "expenses" ? true : false
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
                        console.log(JSON.stringify(operationModel));
                        console.log(JSON.stringify(categoryModel));
                        pageStack.push(Qt.resolvedUrl("../pages/CategoryDetailsPage.qml"), {
                            categoryId: model.categoryId,
                            action: mainpage.action,
                            categoryModel: categoryModel,
                            currentPeriod: currentPeriod
                        });
                }
            }

            VerticalScrollDecorator {}
        }

    function getPeriodDates(period) {
        var now = new Date(); // Фиксируем текущую дату
        var start = new Date(now);
        var end = new Date(now);

        switch(period) {
            case "day":
                start.setHours(0, 0, 0, 0);
                end.setHours(23, 59, 59, 999);
                break;

            case "week":
                var day = start.getDay();
                var diff = start.getDate() - day + (day === 0 ? -6 : 1);
                start.setDate(diff);
                end = new Date(start);
                end.setDate(start.getDate() + 6);
                end.setHours(23, 59, 59, 999);
                break;

            case "month":
                start.setDate(1);
                start.setHours(0, 0, 0, 0);
                end = new Date(start.getFullYear(), start.getMonth() + 1, 0);
                end.setHours(23, 59, 59, 999);
                break;

            case "year":
                start = new Date(now.getFullYear(), 0, 1);
                end = new Date(now.getFullYear(), 11, 31);
                end.setHours(23, 59, 59, 999);
                break;

            case "custom":
                start = startDate;
                end = endDate;
                break;
        }

        // Присваиваем свойствам страницы
        mainpage.startDate = start;
        mainpage.endDate = end;

        return {
            startDate: Qt.formatDate(start, "dd.MM.yyyy"),
            endDate: Qt.formatDate(end, "dd.MM.yyyy")
        };
    }
}
