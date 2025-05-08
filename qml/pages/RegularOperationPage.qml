import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models" as Models
import "../components" as Components
import "../services" as Services

Page {
    id: regularOperationPage
    allowedOrientations: Orientation.All

    property var regularPaymentsModel: Models.RegularPaymentsModel {}
    property var categoryModel
    property var operationService: Services.OperationService {}
    property int selectedCategoryId: -1
    property int action: 0 // 0 - расход, 1 - доход

    // Таймер для тестового режима (каждые 5 секунд)
    Timer {
        id: testTimer
        interval: 5
        running: false
        repeat: true
        onTriggered: processRegularPayments()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: "Регулярные платежи"
            }

            // Переключатель типа операции (доход/расход)
            ComboBox {
                id: actionCombo
                width: parent.width
                label: "Тип операции"
                currentIndex: action
                menu: ContextMenu {
                    MenuItem { text: "Расход" }
                    MenuItem { text: "Доход" }
                }
                onCurrentIndexChanged: {
                    action = currentIndex
                    categorySelector.currentCategoryType = action
                }
            }

            TextField {
                id: amountField
                width: parent.width
                label: "Сумма"
                placeholderText: "Введите сумму"
                inputMethodHints: Qt.ImhDigitsOnly
                validator: DoubleValidator { bottom: 0.01 }
            }

            Components.CategorySelector {
                id: categorySelector
                width: parent.width
                categoryModel: regularOperationPage.categoryModel
                currentCategoryType: action
                onSelectedCategoryIdChanged: {
                    regularOperationPage.selectedCategoryId = selectedCategoryId
                }
            }

            ComboBox {
                id: frequencyCombo
                width: parent.width
                label: "Периодичность"
                currentIndex: 3 // По умолчанию "Каждый месяц"
                menu: ContextMenu {
                    MenuItem { text: "Каждые 5 секунд (тест)" }
                    MenuItem { text: "Каждый день" }
                    MenuItem { text: "Каждую неделю" }
                    MenuItem { text: "Каждые 2 недели" }
                    MenuItem { text: "Каждый месяц" }
                    MenuItem { text: "Каждые 2 месяца" }
                    MenuItem { text: "Каждый квартал" }
                    MenuItem { text: "Каждые полгода" }
                    MenuItem { text: "Каждый год" }
                }
            }

            TextField {
                id: descriptionField
                width: parent.width
                label: "Описание"
                placeholderText: "Назначение платежа"
            }

            Button {
                text: "Добавить платеж"
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: amountField.text && selectedCategoryId > 0 &&
                        selectedCategoryId !== 8 && selectedCategoryId !== 13
                onClicked: addRegularPayment()
            }

            SectionHeader {
                text: "Активные платежи"
                visible: regularPaymentsModel.count > 0
            }

            Repeater {
                model: regularPaymentsModel.payments.filter(function(p) {
                    return p.categoryId !== 8 && p.categoryId !== 13
                })
                delegate: Components.RegularPaymentItem {
                    width: parent.width
                    paymentData: modelData
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
            isIncome: (action === 1),
            nextPaymentDate: calculateNextPaymentDate(frequencyCombo.currentIndex)
        };

        if (regularPaymentsModel.addPayment(payment)) {
            amountField.text = ""
            descriptionField.text = ""
            selectedCategoryId = -1
            categorySelector.selectedCategoryId = -1

            // Если это тестовый режим - запускаем таймер
            if (frequencyCombo.currentIndex === 0) {
                testTimer.start()
            }
        }
    }

    function calculateNextPaymentDate(frequency) {
        var date = new Date()
        switch(frequency) {
            case 0: return date // Для теста (5 секунд)
            case 1: date.setDate(date.getDate() + 1); break // День
            case 2: date.setDate(date.getDate() + 7); break // Неделя
            case 3: date.setDate(date.getDate() + 14); break // 2 недели
            case 4: date.setMonth(date.getMonth() + 1); break // Месяц
            case 5: date.setMonth(date.getMonth() + 2); break // 2 месяца
            case 6: date.setMonth(date.getMonth() + 3); break // Квартал
            case 7: date.setMonth(date.getMonth() + 6); break // Полгода
            case 8: date.setFullYear(date.getFullYear() + 1); break // Год
        }
        return date.toISOString()
    }

    function processRegularPayments() {
        var now = new Date()
        var payments = regularPaymentsModel.payments

        payments.forEach(function(payment) {
            var nextDate = new Date(payment.nextPaymentDate)
            if (now >= nextDate) {
                // Добавляем операцию
                var operation = {
                    amount: payment.amount,
                    action: payment.isIncome ? 1 : 0,
                    categoryId: payment.categoryId,
                    date: Qt.formatDate(now, "dd.MM.yyyy"),
                    desc: payment.description + " (Авто: " +
                          getFrequencyText(payment.frequency) + ")"
                }
                operationService.addOperation(operation)

                // Обновляем дату следующего платежа
                payment.nextPaymentDate = calculateNextPaymentDate(payment.frequency)
                regularPaymentsModel.updatePayment(payment)
            }
        })
    }

    function getFrequencyText(frequency) {
        switch(frequency) {
            case 0: return "Тест 5 сек"
            case 1: return "Ежедневно"
            case 2: return "Еженедельно"
            case 3: return "Каждые 2 недели"
            case 4: return "Ежемесячно"
            case 5: return "Каждые 2 месяца"
            case 6: return "Ежеквартально"
            case 7: return "Каждые полгода"
            case 8: return "Ежегодно"
            default: return ""
        }
    }

    Component.onCompleted: {
        categoryModel.loadCategoriesByType(action)
        regularPaymentsModel.loadPayments()

        // Проверяем регулярные платежи при запуске
        processRegularPayments()
    }
}
