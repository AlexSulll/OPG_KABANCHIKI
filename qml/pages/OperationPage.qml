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

    Models.OperationModel {
        id: operationModel
    }

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

    SilicaFlickable {
            anchors.fill: parent
            contentHeight: column.height

            Column {
                id: column
                width: parent.width
                spacing: Theme.paddingLarge
                anchors.top: parent.top
                anchors.topMargin: Theme.paddingLarge

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

                Button {
                    text: "Сохранить"
                    anchors.horizontalCenter: parent.horizontalCenter
                    enabled: amount !== "" && selectedCategoryId !== -1
                    onClicked: {
                        console.log(amount, action, selectedCategoryId, date, desc)
                        var operationAmount = parseInt(amount);
                        operationModel.add({
                                    amount: operationAmount,
                                    action: action,
                                    categoryId: selectedCategoryId,
                                    date: date,
                                    desc: desc
                        });
                            amount = "";
                            selectedCategoryId = -1;
                            desc = "";
                            pageStack.replaceAbove(null, Qt.resolvedUrl("MainPage.qml"))
                        }
                    }
                }
    }

    Dialog {
        id: dateDialog

        Column {
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                title: "Выберите дату"
                acceptText: "ОК"
                cancelText: "Отмена"
            }

            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: {
                    if (datePicker.date) {
                        var locale = Qt.locale("ru_RU")
                        var monthName = locale.standaloneMonthName(datePicker.date.getMonth())
                        monthName = monthName.charAt(0).toUpperCase() + monthName.slice(1)
                        return monthName + " " + datePicker.date.getFullYear()
                    }
                    return ""
                }
                font.pixelSize: Theme.fontSizeLarge
            }

            DatePicker {
                id: datePicker
                width: parent.width
                date: new Date()
                onDateChanged: {
                    operationPage.date = Qt.formatDate(date, "dd.MM.yyyy");
                }
            }
        }

        onOpened: {
                datePicker.date = new Date()
        }
    }
}
