import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../models" as Models
import "../services" as Services

BasePage {
    id: mainpage
    objectName: "MainPage"

    property string selectedTab: "expenses"
    property int action: 0
    property bool isExpense: action === 0

    property var regularPaymentsModel: Models.RegularPaymentsModel {}
    property var operationService: Services.OperationService {}
    property var categoryModel: Models.CategoryModel {}
    property var sectors: Models.SectorsModel {}

    Timer {
        id: paymentCheckTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: checkRegularPayments()
    }

    Models.CategoryModel {
        id: categoryModel
        Component.onCompleted: {
            loadAllCategories();
        }
    }

    Models.SectorsModel {
        id: sectorModel
    }

    Models.DateFilterModel {
        id: dateFilter
        operationModel: operationModel
    }

    Models.OperationModel {
        id: operationModel
        dateFilterModel: dateFilter
    }

    onVisibleChanged: {
        regularPaymentsModel.loadPayments();
        categoryModel.loadAllCategories();
        operationModel.loadByTypeOperation(selectedTab === "expenses" ? 0 : 1);
        operationModel.calculateTotalBalance();
        sectorModel.calculateChartData(operationModel, mainpage.action);
    }

    Component.onCompleted: {
        categoryModel.loadAllCategories();
        operationModel.loadByTypeOperation(selectedTab === "expenses" ? 0 : 1);
        operationModel.calculateTotalBalance();
        sectorModel.calculateChartData(operationModel, 0);
        regularPaymentsModel.loadPayments();
    }

    HeaderComponent {
        id: header
        headerText: {
            function formatBalance(value) {
                var absValue = Math.abs(value);
                var suffix = "";
                var formattedValue = 0;

                if (absValue >= 1000000000000) {
                    formattedValue = (value / 1000000000000).toFixed(1);
                    suffix = " трлн";
                } else if (absValue >= 1000000000) {
                    formattedValue = (value / 1000000000).toFixed(1);
                    suffix = " млрд";
                } else if (absValue >= 1000000) {
                    formattedValue = (value / 1000000).toFixed(1);
                    suffix = " млн";
                } else {
                    return Number(value).toLocaleString(Qt.locale(), 'f', 0) + " ₽";
                }

                formattedValue = formattedValue.replace(".", ",").replace(",0", "");
                return formattedValue + suffix + " ₽";
            }

            return formatBalance(operationModel.totalBalance);
        }
        selectedTab: mainpage.selectedTab
        onSelectedTabChanged: {
            mainpage.selectedTab = header.selectedTab;
            mainpage.action = header.selectedTab === "expenses" ? 0 : 1;
            operationModel.loadByTypeOperation(mainpage.action);
            operationModel.calculateTotalBalance();
            analyticsCard.isExpense = mainpage.action === 0;
            sectorModel.calculateChartData(operationModel, mainpage.action);
        }
    }

    MainCardComponent {
        id: analyticsCard
        operationModel: operationModel
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

            property var categoryData: categoryModel.getCategoryById(model.categoryId)

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
                        text: qsTr(categoryData ? categoryData.nameCategory : "Без категории")
                        color: Theme.primaryColor
                        anchors {
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
                        text: isNaN(model.total) ? "0 ₽" : Number(model.total).toLocaleString(Qt.locale(), 'f', 0) + " ₽"
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
                    categoryModel: categoryModel,
                    currentPeriod: dateFilter.currentPeriod,
                    dateFilterModel: dateFilter
                });
            }
        }

        VerticalScrollDecorator {}
    }

    function checkRegularPayments() {
        var now = new Date();
        var payments = regularPaymentsModel.payments;
        var processedCount = 0;

        for (var i = 0; i < payments.length; i++) {
            var payment = payments[i];
            var nextDate = new Date(payment.nextPaymentDate);
            var lastProcessed = new Date(payment.lastProcessedDate || 0);

            if (nextDate <= now && nextDate > lastProcessed) {
                var operation = {
                    amount: payment.amount,
                    action: payment.isIncome ? 1 : 0,
                    categoryId: payment.categoryId,
                    date: Qt.formatDate(nextDate, "dd.MM.yyyy"),
                    desc: payment.description + " (Автоплатеж)"
                };

                if (operationService.addOperation(operation)) {
                    payment.lastProcessedDate = nextDate.toISOString();
                    payment.nextPaymentDate = regularPaymentsModel.calculateNextDate(nextDate, payment.frequency);
                    regularPaymentsModel.updatePayment(payment);

                    processedCount++;
                    console.log("Добавлена операция для платежа ID:", payment.id);
                }
            }
        }

        if (processedCount > 0) {
            console.log("Обработано платежей:", processedCount);
            operationModel.loadByTypeOperation(action);
        }
    }
}
