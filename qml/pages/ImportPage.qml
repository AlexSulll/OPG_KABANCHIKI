import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import "../models" as Models
import "../components" as Components

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

    Components.HeaderCategoryComponent {
        id: header
        fontSize: Theme.fontSizeExtraLarge * 1.2
        color: "transparent"
        headerText: "Импорт операций"
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
                visible: importStatus !== ""
            }

            Button {
                id: okButton
                text: "Ок"
                anchors.horizontalCenter: parent.horizontalCenter
                visible: importStatus.indexOf("Импорт завершен") === 0
                onClicked: pageStack.replaceAbove(null, Qt.resolvedUrl("MainPage.qml"))
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
                    var filePath = "" + selectedContentProperties.filePath;
                    if (filePath.indexOf("file://") === 0) {
                        filePath = filePath.substring(7);
                    }
                    importOperations(filePath);
                }
            }
        }
    }

    function importOperations(filePath) {
        importInProgress = true;
        importStatus = "Чтение файла...";

        categoryModel.loadAllCategories();
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "file://" + filePath, false);
        xhr.send();

        if (xhr.status !== 200 && xhr.status !== 0) {
            importStatus = "Ошибка чтения файла: " + xhr.status;
            importInProgress = false;
            return;
        }

        var csvData = xhr.responseText;
        if (!csvData || csvData.trim().length === 0) {
            importStatus = "Файл пустой";
            importInProgress = false;
            return;
        }

        var lines = csvData.split('\n');
        var importedCount = 0;
        var errors = [];
        for (var i = 1; i < lines.length; i++) {
            var line = lines[i].trim();
            if (!line)
                continue;
            var fields = parseCsvLine(line);
            var allEmpty = true;
            for (var f = 0; f < fields.length; f++) {
                if (fields[f].trim() !== "") {
                    allEmpty = false;
                    break;
                }
            }
            if (allEmpty)
                continue;
            if (fields.length !== 5) {
                continue;
            }

            try {
                var operation = {
                    date: fields[0] // формат dd.MM.yyyy
                    ,
                    categoryId: categoryModel.getCategoryIdByName(fields[1]),
                    amount: parseFloat(fields[2]),
                    action: fields[3] === "Доход" ? 1 : 0,
                    desc: fields[4]
                };

                if (operation.categoryId === undefined || operation.categoryId === null || operation.categoryId === -1) {
                    continue;
                }

                if (isNaN(operation.amount)) {
                    continue;
                }

                if (!operation.date.match(/^\d{2}\.\d{2}\.\d{4}$/)) {
                    continue;
                }

                operationModel.add(operation);
                importedCount++;
            } catch (e) {
                continue;
            }
        }

        importStatus = "Импорт завершен\nУспешно: " + importedCount;

        importInProgress = false;
    }

    function parseCsvLine(line) {
        var fields = [];
        var current = "";
        var inQuotes = false;

        for (var i = 0; i < line.length; i++) {
            var c = line[i];
            if (c === '"') {
                inQuotes = !inQuotes;
            } else if (c === ',' && !inQuotes) {
                fields.push(current.trim());
                current = "";
            } else {
                current += c;
            }
        }
        fields.push(current.trim());

        return fields;
    }
}
