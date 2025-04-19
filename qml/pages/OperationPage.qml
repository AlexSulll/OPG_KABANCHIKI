import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: operationPage
    allowedOrientations: Orientation.All

    property var operationService
    property var categoryModel

    property string amount: ""
    property int selectedCategoryId
    property int action
    property string date: Qt.formatDate(new Date(), "dd.MM.yyyy")
    property string desc: ""

    onAmountChanged: {
        console.log(JSON.stringify(categoryModel))
        console.log(JSON.stringify(selectedCategoryId))
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
                            Qt.callLater(function() { pageStack.pop(); });
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
