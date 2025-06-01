import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models" as Models
import "../components" as Components
import "../services" as Services

Page {
    id: regularOperationPage
    allowedOrientations: Orientation.All

    property var regularPaymentsModel: Models.RegularPaymentsModel {}
    property var categoryModel: Models.CategoryModel {}
    property var operationService: Services.OperationService {}
    property int selectedCategoryId: -1
    property int action: 0

    Components.HeaderCategoryComponent {
        id: header
        fontSize: Theme.fontSizeExtraLarge * 1.2
        color: "transparent"
        headerText: qsTr("Регулярные платежи")
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    SilicaFlickable {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            ComboBox {
                id: actionCombo
                width: parent.width
                label: "Тип операции"
                currentIndex: action
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Расход")
                    }
                    MenuItem {
                        text: qsTr("Доход")
                    }
                }
                onCurrentIndexChanged: {
                    action = currentIndex;
                    categoryModel.loadCategoriesByType(action);
                    categorySelector.resetSelection();
                    action = currentIndex;
                }
            }

            TextField {
                id: amountField
                width: parent.width
                label: qsTr("Сумма")
                placeholderText: qsTr("Введите сумму")
                inputMethodHints: Qt.ImhDigitsOnly
                validator: DoubleValidator {
                    bottom: 0.01
                }
            }

            Components.CategorySelector {
                id: categorySelector
                width: parent.width
                categoryModel: regularOperationPage.categoryModel
                currentCategoryType: action
                onSelectedCategoryIdChanged: {
                    regularOperationPage.selectedCategoryId = selectedCategoryId;
                }
            }

            ComboBox {
                id: frequencyCombo
                width: parent.width
                label: qsTr("Периодичность")
                currentIndex: 3
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Каждый день")
                    }
                    MenuItem {
                        text: qsTr("Каждую неделю")
                    }
                    MenuItem {
                        text: qsTr("Каждые 2 недели")
                    }
                    MenuItem {
                        text: qsTr("Каждый месяц")
                    }
                    MenuItem {
                        text: qsTr("Каждые 2 месяца")
                    }
                    MenuItem {
                        text: qsTr("Каждый квартал")
                    }
                    MenuItem {
                        text: qsTr("Каждые полгода")
                    }
                    MenuItem {
                        text: qsTr("Каждый год")
                    }
                }
            }

            TextField {
                id: descriptionField
                width: parent.width
                label: qsTr("Описание")
                placeholderText: qsTr("Назначение платежа")
            }

            Button {
                text: qsTr("Добавить платеж")
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: amountField.text && selectedCategoryId > 0
                onClicked: addRegularPayment()
            }

            SectionHeader {
                text: qsTr("Активные платежи")
                visible: regularPaymentsModel.count > 0
            }

            Repeater {
                model: regularPaymentsModel.payments
                delegate: Components.RegularPaymentItem {
                    width: parent.width
                    paymentData: modelData
                    categoryModel: regularOperationPage.categoryModel
                    onDeleteRequested: regularPaymentsModel.removePayment(modelData.id)
                }
            }
        }
    }

    function addRegularPayment() {
        var payment = {
            amount: parseFloat(amountField.text),
            categoryId: selectedCategoryId,
            frequency: frequencyCombo.currentIndex,
            description: descriptionField.text,
            isIncome: actionCombo.currentIndex,
            nextPaymentDate: calculateNextPaymentDate(frequencyCombo.currentIndex)
        };

        if (regularPaymentsModel.addPayment(payment)) {
            amountField.text = "";
            descriptionField.text = "";
            selectedCategoryId = -1;
            categorySelector.selectedCategoryId = -1;
        }
    }

    function calculateNextPaymentDate(frequency) {
        var date = new Date();
        switch (frequency) {
        case 0:
            date.setDate(date.getDate() + 1);
            break;
        case 1:
            date.setDate(date.getDate() + 7);
            break;
        case 2:
            date.setDate(date.getDate() + 14);
            break;
        case 3:
            date.setMonth(date.getMonth() + 1);
            break;
        case 4:
            date.setMonth(date.getMonth() + 2);
            break;
        case 5:
            date.setMonth(date.getMonth() + 3);
            break;
        case 6:
            date.setMonth(date.getMonth() + 6);
            break;
        case 7:
            date.setFullYear(date.getFullYear() + 1);
            break;
        }

        return date.toISOString();
    }

    Component.onCompleted: {
        categoryModel.loadCategoriesByType(action);
        regularPaymentsModel.loadPayments();
        categorySelector.resetSelection();
    }
}
