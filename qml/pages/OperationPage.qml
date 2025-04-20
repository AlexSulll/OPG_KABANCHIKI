import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components" as Components
import "../services" as Services
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

    Services.CategoryService {
        id: categoryService
    }

    Services.OperationService {
        id: operationService
    }

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
                var categories = categoryService.loadCategoriesByCategoryId(selectedCategoryId);
                if (categories.length > 0) {
                    selectedCategory = categories[0];
                    console.log("Категория:", selectedCategory.nameCategory);
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

                // Кнопка сохранения
                Button {
                    text: "Сохранить"
                    anchors.horizontalCenter: parent.horizontalCenter
                    enabled: amount !== "" && selectedCategoryId !== -1
                    onClicked: {
                        console.log(amount, action, selectedCategoryId, date, desc)
                        var operationAmount = parseInt(amount);
                        operationService.addOperation({
                                    amount: operationAmount,
                                    action: action,
                                    categoryId: selectedCategoryId,
                                    date: date,
                                    desc: desc
                        });
                            operationModel.refresh();

                            amount = "";
                            selectedCategoryId = -1;
                            desc = "";
                            pageStack.replaceAbove(null, Qt.resolvedUrl("MainPage.qml"))
                        }
                    }
                }
                Dialog {
                    id: dateDialog
                    width: parent.width

                    DatePicker {
                        id: datePicker
                        date: new Date()
                        onDateChanged: {
                                operationPage.date = Qt.formatDate(date, "dd.MM.yyyy");
                                dateDialog.close();
                        }
                    }
                }
            }
    }
