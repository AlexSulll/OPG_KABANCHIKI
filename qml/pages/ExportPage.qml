import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.DBus 2.0
import Nemo.Configuration 1.0
import "../models" as Models

Page {
    id: exportPage
    allowedOrientations: Orientation.All

    property string exportStatus: ""
    property bool exportInProgress: false
    property string suggestedFileName: ""
    property var operations: []

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

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: "Экспорт операций"
            }

            ComboBox {
                id: periodCombo
                width: parent.width
                label: "Период экспорта"
                menu: ContextMenu {
                    MenuItem { text: "За последний месяц" }
                    MenuItem { text: "За последние 3 месяца" }
                    MenuItem { text: "За все время" }
                }
            }

            ComboBox {
                id: typeCombo
                width: parent.width
                label: "Тип операций"
                menu: ContextMenu {
                    MenuItem { text: "Все операции" }
                    MenuItem { text: "Только доходы" }
                    MenuItem { text: "Только расходы" }
                }
            }

            TextField {
                id: fileNameField
                width: parent.width
                label: "Имя файла"
                placeholderText: "Введите имя файла"
                text: suggestedFileName
            }

            Button {
                text: "Экспортировать в файл"
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: !exportInProgress && fileNameField.text.length > 0
                onClicked: {
                    // Сначала получаем данные
                    getOperationsForExport()
                }
            }

            Button {
                text: "Импорт"
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: !exportInProgress && fileNameField.text.length > 0
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../pages/ImportPage.qml"), {
                    });
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
        suggestedFileName = "operations_" + Qt.formatDateTime(new Date(), "yyyyMMdd") + ".csv"
    }

    function getOperationsForExport() {
        exportInProgress = true
        exportStatus = "Получение данных..."

        // Вызываем метод модели для получения операций
        operations = operationModel.getOperationsForExport({
            period: periodCombo.currentIndex,
            type: typeCombo.currentIndex
        })

        if (operations && operations.length > 0) {
            exportStatus = "Найдено операций: " + operations.length
            prepareExportData()
        } else {
            exportStatus = "Нет операций для экспорта"
            exportInProgress = false
        }
    }

    function prepareExportData() {
            exportStatus = "Подготовка данных..."

            // Формируем CSV заголовок
            var csvData = "Дата,Категория,Сумма,Тип,Описание\n"

            for (var i = 0; i < operations.length; i++) {
                var op = operations[i]
                var categoryName = categoryModel.getCategoryName(op.categoryId) || "Без категории"

                // Экранируем специальные символы
                var desc = op.description || ""
                desc = desc.replace(/"/g, '""') // Экранируем кавычки

                csvData += '"' + op.date + '","' +
                          categoryName + '",' +
                          op.amount + ',"' +
                          (op.type === 1 ? "Доход" : "Расход") + '","' +
                          desc + '"\n'
            }

            var fullPath = saveToFile(csvData)

            if (fullPath) {
                pageStack.push(Qt.resolvedUrl("ExportResultDialog.qml"), {
                    fileName: fileNameField.text,
                    dataSize: csvData.length,
                    operationsCount: operations.length,
                    sampleData: csvData.substring(0, 300) + (csvData.length > 300 ? "..." : "")
                })
            } else {
                exportStatus = "Ошибка сохранения файла"
            }

            exportInProgress = false
        }

    function saveToFile(textData) {
            var filePath = documentsPath.value + "/" + fileNameField.text

            try {
                // Используем FileIO из QtDocs или аналоги
                if (typeof FileIO !== 'undefined') {
                    FileIO.write(filePath, textData)
                    return filePath
                }
                // Альтернативный вариант через XMLHttpRequest
                else {
                    var xhr = new XMLHttpRequest()
                    xhr.open("PUT", "file://" + filePath, false)
                    xhr.send(textData)
                    return (xhr.status === 0 || xhr.status === 200) ? filePath : ""
                }
            } catch(e) {
                console.log("Error saving file:", e)
                return ""
            }
        }
}
