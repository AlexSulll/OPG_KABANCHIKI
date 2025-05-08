import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models" as Models

Page {
    id: exportPage
    allowedOrientations: Orientation.All

    property var operationModel

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
                currentIndex: 0
                menu: ContextMenu {
                    MenuItem { text: "За последний месяц" }
                    MenuItem { text: "За последние 3 месяца" }
                    MenuItem { text: "За последний год" }
                    MenuItem { text: "За все время" }
                }
            }

            ComboBox {
                id: typeCombo
                width: parent.width
                label: "Тип операций"
                currentIndex: 0
                menu: ContextMenu {
                    MenuItem { text: "Все операции" }
                    MenuItem { text: "Только доходы" }
                    MenuItem { text: "Только расходы" }
                }
            }

            TextSwitch {
                id: includeHeaderSwitch
                text: "Включать заголовки столбцов"
                checked: true
            }

            Button {
                text: "Сформировать CSV"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: generateCSV()
            }

            Label {
                id: statusLabel
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: Theme.highlightColor
                wrapMode: Text.Wrap
            }

            Button {
                text: "Поделиться файлом"
                anchors.horizontalCenter: parent.horizontalCenter
                visible: exportPath !== ""
                onClicked: shareFile()
            }
        }
    }

    property string exportPath: ""

    function generateCSV() {
        var period = periodCombo.currentIndex;
        var type = typeCombo.currentIndex;
        var includeHeader = includeHeaderSwitch.checked;

        var csvData = operationModel.exportToCSV(period, type, includeHeader);

        if (csvData) {
            exportPath = csvData.filePath;
            statusLabel.text = "Файл сохранен: " + csvData.fileName +
                             "\nОпераций экспортировано: " + csvData.recordCount;
        } else {
            statusLabel.text = "Ошибка при экспорте данных";
        }
    }

    function shareFile() {
        if (exportPath !== "") {
            Qt.openUrlExternally("file://" + exportPath);
        }
    }
}
