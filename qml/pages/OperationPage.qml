import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components" as Components
import "../models" as Models

Page {
    id: operationPage
    allowedOrientations: Orientation.All
    anchors.centerIn: parent

    property string amount: ""
    property int selectedCategoryId: -1
    property int action: 0
    property string date: Qt.formatDate(new Date(), "dd.MM.yyyy")
    property string desc: ""

    property var selectedCategory: null
    property var operationModel
    property var categoryModel
    property var limitModel: Models.LimitModel {}
    property bool fromMainButton: true

    // Свойства для хранения данных о лимите
    property real categoryLimit: 0
    property real currentSpent: 0
    property real operationAmount: 0

    onActionChanged: {
        if (categoryModel) {
            categoryModel.loadCategoriesByType(action);
        }
    }

    Component.onCompleted: {
        if (selectedCategoryId !== -1) {
            var categories = categoryModel.loadCategoriesByCategoryId(selectedCategoryId);
            if (categories.length > 0) {
                selectedCategory = categories[0];
            }
        }
    }

    Components.HeaderCategoryComponent {
        id: header
        fontSize: Theme.fontSizeExtraLarge*2
        color: "transparent"
        headerText: fromMainButton ? "Добавление" : "Категории"
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
        anchors.topMargin: header.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge
            anchors.top: header.bottom

            TextField {
                id: sumInput
                width: parent.width
                placeholderText: "Сумма (руб)"
                inputMethodHints: Qt.ImhDigitsOnly
                validator: IntValidator { bottom: 1 }
                onTextChanged: amount = text
            }

            Components.CategoryDisplay {
                width: parent.width
                categoryData: selectedCategory
            }

            TextField {
                width: parent.width
                placeholderText: "Дата"
                text: date
                onClicked: dateDialog.open()
            }

            TextArea {
                width: parent.width
                height: Theme.itemSizeLarge
                placeholderText: qsTr("Комментарий")
                inputMethodHints: Qt.ImhNoPredictiveText
                onTextChanged: operationPage.desc = text
            }

            Row {
                width: parent.width
                spacing: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    text: "Отмена"
                    width: (parent.width - parent.spacing) / 2
                    color: "red"
                    onClicked: pageStack.pop()
                }

                Button {
                    text: "Сохранить"
                    width: (parent.width - parent.spacing) / 2
                    enabled: amount !== "" && selectedCategoryId !== -1
                    onClicked: checkAndSaveOperation()
                }
            }
        }
    }

    Dialog {
        id: dateDialog
        allowedOrientations: Orientation.All

        Column {
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: "Выберите дату"
                acceptText: "ОК"
                cancelText: "Отмена"
            }

            Row {
                width: parent.width
                spacing: Theme.paddingMedium

                ComboBox {
                    id: monthCombo
                    width: parent.width / 2 - Theme.paddingMedium/2
                    label: "Месяц"
                    currentIndex: datePicker.date.getMonth()

                    menu: ContextMenu {
                        Repeater {
                            model: {
                                var locale = Qt.locale("ru_RU")
                                var months = []
                                for (var i = 0; i < 12; i++) {
                                    var monthName = locale.standaloneMonthName(i, Locale.LongFormat)
                                    months.push(monthName.charAt(0).toUpperCase() + monthName.slice(1))
                                }
                                return months
                            }
                            MenuItem { text: modelData }
                        }
                    }

                    onCurrentIndexChanged: {
                        if (datePicker.date) {
                            var newDate = new Date(datePicker.date)
                            newDate.setMonth(currentIndex)
                            datePicker.date = newDate
                        }
                    }
                }

                ComboBox {
                    id: yearCombo
                    width: parent.width / 2 - Theme.paddingMedium/2
                    label: "Год"
                    currentIndex: 5

                    property var years: (function() {
                        var arr = []
                        var currentYear = new Date().getFullYear()
                        for (var i = currentYear - 3; i <= currentYear + 3; i++) {
                            arr.push(i)
                        }
                        return arr
                    })()

                    menu: ContextMenu {
                        Repeater {
                            model: yearCombo.years
                            MenuItem { text: modelData }
                        }
                    }

                    onCurrentIndexChanged: {
                        if (datePicker.date) {
                            var newDate = new Date(datePicker.date)
                            newDate.setFullYear(years[currentIndex])
                            datePicker.date = newDate
                        }
                    }
                }
            }

            DatePicker {
                id: datePicker
                width: parent.width
                date: new Date()

                onDateChanged: {
                    // Синхронизация с комбобоксами
                    monthCombo.currentIndex = date.getMonth()
                    yearCombo.currentIndex = yearCombo.years.indexOf(date.getFullYear())
                    operationPage.date = Qt.formatDate(date, "dd.MM.yyyy")
                }
            }
        }

        onOpened: {
            var today = new Date()
            datePicker.date = today
        }

        onAccepted: {
            operationPage.date = Qt.formatDate(datePicker.date, "dd.MM.yyyy")
        }
    }

    Dialog {
        id: limitExceededDialog
        allowedOrientations: Orientation.All

        Column {
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: qsTr("Превышение лимита")
                acceptText: qsTr("Все равно сохранить")
                cancelText: qsTr("Отменить")
            }

            Label {
                width: parent.width
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Вы превысите лимит на %1 руб.").arg((operationPage.currentSpent + operationPage.operationAmount - operationPage.categoryLimit).toFixed(2))
                color: Theme.errorColor
                font.pixelSize: Theme.fontSizeMedium
            }

            Label {
                width: parent.width
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Лимит: %1 руб.").arg(operationPage.categoryLimit.toFixed(2))
            }

            Label {
                width: parent.width
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Уже потрачено: %1 руб.").arg(operationPage.currentSpent.toFixed(2))
            }

            Label {
                width: parent.width
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Новая операция: %1 руб.").arg(operationPage.operationAmount.toFixed(2))
            }
        }

        onAccepted: saveOperation()
    }

    function checkAndSaveOperation() {
        operationAmount = parseInt(amount);
        if (isNaN(operationAmount)) return;

        categoryLimit = limitModel.getLimit(selectedCategoryId);
        if (categoryLimit === null || categoryLimit === undefined || categoryLimit === 0) {
            saveOperation();
            return;
        }

        currentSpent = operationModel.getTotalSpentByCategory(selectedCategoryId);
        if (currentSpent + operationAmount > categoryLimit) {
            limitExceededDialog.open();
        } else {
            saveOperation();
        }
    }

    function saveOperation() {
        operationModel.add({
            amount: operationAmount,
            action: action,
            categoryId: selectedCategoryId,
            date: date,
            desc: desc
        });
        pageStack.replaceAbove(null, Qt.resolvedUrl("MainPage.qml"));
    }
}
