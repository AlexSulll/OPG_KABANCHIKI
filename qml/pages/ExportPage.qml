import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.DBus 2.0
import Nemo.Configuration 1.0
import "../models" as Models
import "../components" as Components

Page {
    id: exportPage
    allowedOrientations: Orientation.All

    property string exportStatus: ""
    property bool exportInProgress: false
    property string suggestedFileName: ""
    property var operations: []

    property int selectedPeriod: 0
    property int selectedType: 0

    ConfigurationValue {
        id: documentsPath
        key: "/desktop/nemo/preferences/documents_path"
        defaultValue: StandardPaths.documents
    }

    Models.OperationModel {
        id: operationModel
    }

    Models.CategoryModel {
        id: categoryModel
        Component.onCompleted: loadAllCategories()
    }

    Components.HeaderCategoryComponent {
        id: header
        fontSize: Theme.fontSizeExtraLarge * 1.2
        color: "transparent"
        headerText: qsTr("Экспорт операций")
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
                id: periodCombo
                width: parent.width
                label: qsTr("Период экспорта")
                currentIndex: selectedPeriod
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("За последний месяц")
                    }
                    MenuItem {
                        text: qsTr("За последние 3 месяца")
                    }
                    MenuItem {
                        text: qsTr("За все время")
                    }
                }
                onCurrentIndexChanged: {
                    selectedPeriod = currentIndex;
                    updateOperations();
                }
            }

            ComboBox {
                id: typeCombo
                width: parent.width
                label: qsTr("Тип операций")
                currentIndex: selectedType
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Все операции")
                    }
                    MenuItem {
                        text: qsTr("Только доходы")
                    }
                    MenuItem {
                        text: qsTr("Только расходы")
                    }
                }
                onCurrentIndexChanged: {
                    selectedType = currentIndex;
                    updateOperations();
                }
            }

            TextField {
                id: fileNameField
                width: parent.width
                label: qsTr("Имя файла")
                placeholderText: qsTr("Введите имя файла")
                text: suggestedFileName
            }

            Button {
                text: qsTr("Экспортировать в файл")
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: !exportInProgress && fileNameField.text.length > 0
                onClicked: {
                    var ops = getOperationsForExport();
                    if (ops && ops.length > 0) {
                        prepareExportData();
                    } else {
                        exportStatus = qsTr("Нет операций для экспорта");
                    }
                }
            }

            Label {
                id: statusLabel
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: Theme.highlightColor
                wrapMode: Text.Wrap
                text: exportStatus
            }
        }
    }

    Component.onCompleted: {
        suggestedFileName = "operations_" + Qt.formatDateTime(new Date(), "yyyyMMdd") + ".csv";
        periodCombo.currentIndex = 0;
        typeCombo.currentIndex = 0;
        selectedPeriod = 0;
        selectedType = 0;
        updateOperations();
    }

    function getOperationsForExport() {
        exportInProgress = true;
        exportStatus = "Получение данных...";
        operations = operationModel.getOperationsForExport({
            period: periodCombo.currentIndex,
            type: typeCombo.currentIndex
        });

        exportInProgress = false;

        if (operations && operations.length > 0) {
            exportStatus = "Найдено операций: " + operations.length;
            return operations;
        } else {
            exportStatus = "Нет операций для экспорта";
            return [];
        }
    }

    function prepareExportData() {
        exportStatus = "Подготовка данных...";
        var csvData = "Дата,Категория,Сумма,Тип,Описание\n";

        for (var i = 0; i < operations.length; i++) {
            var op = operations[i];
            var categoryName = categoryModel.getCategoryName(op.categoryId) || "Без категории";
            var desc = op.description || "";
            desc = desc.replace(/"/g, '""'); // Экранируем кавычки

            csvData += '"' + op.date + '","' + categoryName + '",' + op.amount + ',"' + (op.action === 1 ? "Доход" : "Расход") + '","' + desc + '"\n';
        }

        var fullPath = saveToFile(csvData);

        if (fullPath) {
            pageStack.push(Qt.resolvedUrl("ExportResultDialog.qml"), {
                fileName: fileNameField.text,
                dataSize: csvData.length,
                operationsCount: operations.length,
                sampleData: csvData.substring(0, 300) + (csvData.length > 300 ? "..." : "")
            });
        } else {
            exportStatus = "Ошибка сохранения файла";
        }

        exportInProgress = false;
    }

    function saveToFile(textData) {
        var filePath = documentsPath.value + "/" + fileNameField.text;

        try {
            if (typeof FileIO !== 'undefined') {
                FileIO.write(filePath, textData);
                return filePath;
            } else
            {
                var xhr = new XMLHttpRequest();
                xhr.open("PUT", "file://" + filePath, false);
                xhr.send(textData);
                return (xhr.status === 0 || xhr.status === 200) ? filePath : "";
            }
        } catch (e) {
            console.log("Error saving file:", e);
            return "";
        }
    }

    function updateOperations() {
        exportInProgress = true;
        exportStatus = "Получение данных...";
        operations = operationModel.getOperationsForExport({
            period: selectedPeriod,
            type: selectedType
        });
        if (operations && operations.length > 0) {
            exportStatus = "Найдено операций: " + operations.length;
        } else {
            exportStatus = "Нет операций для экспорта";
        }
        exportInProgress = false;
    }
}
