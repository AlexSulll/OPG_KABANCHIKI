import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import "../models" as Models

Page {
    id: importPage
    allowedOrientations: Orientation.All

    property bool importInProgress: false
    property string importStatus: ""

    Models.OperationModel {
        id: operationModel
    }

    Models.CategoryModel {
        id: categoryModel
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: "Импорт операций"
            }

            Button {
                text: "Выбрать CSV файл"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: pageStack.push(csvFilePicker)
            }

            Label {
                id: statusLabel
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: Theme.highlightColor
                wrapMode: Text.Wrap
                text: importStatus
            }
        }
    }

    Component {
        id: csvFilePicker

        FilePickerPage {
            title: qsTr("Выберите файл CSV")
            nameFilters: ['*.csv']
            allowedOrientations: Orientation.All

            onSelectedContentPropertiesChanged: {
                if (selectedContentProperties !== null) {
                    var filePath = selectedContentProperties.filePath
                    // Убираем префикс file:// если присутствует
                    if (filePath.startsWith("file://")) {
                        filePath = filePath.substring(7)
                    }
                    importOperations(filePath)
                }
            }
        }
    }

    function importOperations(filePath) {
        importInProgress = true
        importStatus = "Чтение файла..."

        // Читаем файл через XMLHttpRequest
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "file://" + filePath, false)
        xhr.send()

        if (xhr.status !== 200) {
            importStatus = "Ошибка чтения файла: " + xhr.status
            importInProgress = false
            return
        }

        var csvData = xhr.responseText
        var lines = csvData.split('\n')
        var importedCount = 0
        var errors = []

        // Парсим CSV
        for (var i = 1; i < lines.length; i++) { // Пропускаем заголовок
            var line = lines[i].trim()
            if (!line) continue

            var fields = parseCsvLine(line)
            if (fields.length !== 5) {
                errors.push("Строка " + i + ": Некорректное количество полей")
                continue
            }

            try {
                var operation = {
                    date: fields[0],
                    category: categoryModel.getCategoryIdByName(fields[1]),
                    amount: parseFloat(fields[2]),
                    type: fields[3] === "Доход" ? 1 : 0,
                    description: fields[4]
                }

                if (operationModel.addOperation(operation)) {
                    importedCount++
                } else {
                    errors.push("Строка " + i + ": Ошибка сохранения")
                }
            } catch(e) {
                errors.push("Строка " + i + ": " + e.message)
            }
        }

        importStatus = "Импорт завершен\n
                       Успешно: ${importedCount}\n
                       Ошибок: ${errors.length}"

        if (errors.length > 0) {
            pageStack.push(Qt.resolvedUrl("ImportErrorsDialog.qml"), {
                errors: errors
            })
        }

        importInProgress = false
    }

    function parseCsvLine(line) {
        var fields = []
        var current = ""
        var inQuotes = false

        for (var i = 0; i < line.length; i++) {
            var c = line[i]
            if (c === '"') {
                inQuotes = !inQuotes
            } else if (c === ',' && !inQuotes) {
                fields.push(current.trim())
                current = ""
            } else {
                current += c
            }
        }
        fields.push(current.trim())

        return fields
    }
}
