import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components" as Components

Page {
    id: operationPage
    allowedOrientations: Orientation.All
    anchors.centerIn: parent

    property var operationService
    property var categoryModel
    property var selectedCategory: {
        if(categoryModel && selectedCategoryId !== -1) {
            return categoryModel.getCategoryById(selectedCategoryId)
        }
        return null
    }
    property var mainPage: null

    property string amount: ""
    property int selectedCategoryId: -1
    property int action: 0
    property string date: Qt.formatDate(new Date(), "dd.MM.yyyy")
    property string desc: ""

    //Ломает почему-то
    onStatusChanged: {
//        if (status === PageStatus.Active) {
//            mainPage = pageStack.find(function(page) {
//                return page.objectName === "MainPage";
//            });
        if (categoryModel) {
            categoryModel.loadCategoriesByType(action)
        }
    }

    onAmountChanged: {
        console.log(JSON.stringify(categoryModel))
        console.log(JSON.stringify(selectedCategory))
        console.log(JSON.stringify(action))
//        if (categoryModel) {
//            categoryModel.loadCategoriesByType(action);
//        }
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
                        if (operationService) {
                            operationService.addOperation({
                                amount: parseInt(amount),
                                action: action,
                                category: selectedCategoryId,
                                date: date,
                                desc: desc
                            });

                            if (mainPage.operationModel) {
                                mainPage.operationModel.refresh();
                            }

                            pageStack.pop(mainPage);

                            amount = "";
                            selectedCategoryId = -1;
                            desc = "";

                            if (mainPage) mainPage.refreshOperations()
                            pageStack.pop()
//                            Qt.callLater(function() { pageStack.pop(); });
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
}
