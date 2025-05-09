import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models" as Models
import "../services" as Services
import Qt.labs.folderlistmodel 2.1

Page {
    id: exportPage
    allowedOrientations: Orientation.All

    property var operationModel
    property var fileService: Services.FileService {}
    property string exportPath: ""
    property bool exportInProgress: false

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: "Очистить историю экспорта"
                onClicked: clearExportHistory()
            }
        }

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
                    MenuItem { text: "За последние 6 месяцев" }
                    MenuItem { text: "За последний год" }
                    MenuItem { text: "За все время" }
                    MenuItem { text: "Произвольный период" }
                }
            }

            DatePicker {
                id: startDatePicker
                width: parent.width
                date: new Date(Date.now() - 30*24*60*60*1000) // 30 дней назад
                visible: periodCombo.currentIndex === 5
            }

            DatePicker {
                id: endDatePicker
                width: parent.width
                date: new Date()
                visible: periodCombo.currentIndex === 5
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

            ComboBox {
                id: formatCombo
                width: parent.width
                label: "Формат экспорта"
                currentIndex: 0
                menu: ContextMenu {
                    MenuItem { text: "CSV (Excel)" }
                    MenuItem { text: "JSON" }
                    MenuItem { text: "XML" }
                }
            }

            TextSwitch {
                id: includeHeaderSwitch
                text: "Включать заголовки столбцов"
                checked: true
                visible: formatCombo.currentIndex === 0
            }

            Button {
                text: "Сформировать отчет"
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: !exportInProgress
                onClicked: generateExportFile()
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
                visible: exportPath !== "" && !exportInProgress
                onClicked: shareFile()
            }

            Button {
                text: "Открыть папку с файлами"
                anchors.horizontalCenter: parent.horizontalCenter
                visible: exportPath !== "" && !exportInProgress
                onClicked: openExportFolder()
            }
        }
    }

    function generateExportFile() {
        exportInProgress = true
        statusLabel.text = "Формирование отчета..."

        var period = periodCombo.currentIndex
        var type = typeCombo.currentIndex
        var format = formatCombo.currentIndex
        var includeHeader = includeHeaderSwitch.checked

        var startDate = period === 5 ? startDatePicker.date : null
        var endDate = period === 5 ? endDatePicker.date : null

        var result = operationModel.exportOperations({
            period: period,
            type: type,
            format: format,
            includeHeader: includeHeader,
            startDate: startDate,
            endDate: endDate
        })

        if (result.success) {
            exportPath = result.filePath
            statusLabel.text = "Файл успешно сохранен:\n" + result.fileName +
                             "\nОпераций экспортировано: " + result.count +
                             "\nРазмер: " + formatFileSize(result.fileSize)
        } else {
            statusLabel.text = "Ошибка: " + result.error
        }

        exportInProgress = false
    }

    function shareFile() {
        if (exportPath !== "") {
            Qt.openUrlExternally("file://" + exportPath)
        }
    }

    function openExportFolder() {
        var folder = fileService.getExportFolder()
        Qt.openUrlExternally("file://" + folder)
    }

    function clearExportHistory() {
        if (fileService.clearExportFolder()) {
            exportPath = ""
            statusLabel.text = "История экспорта очищена"
        } else {
            statusLabel.text = "Ошибка при очистке истории"
        }
    }

    function formatFileSize(bytes) {
        if (bytes < 1024) return bytes + " Б"
        if (bytes < 1048576) return (bytes/1024).toFixed(1) + " КБ"
        return (bytes/1048576).toFixed(1) + " МБ"
    }

    Component.onCompleted: {
        // Проверяем доступность места при загрузке страницы
        var storageInfo = fileService.checkStorage()
        if (!storageInfo.hasSpace) {
            statusLabel.text = "Внимание: мало свободного места (" +
                             formatFileSize(storageInfo.freeSpace) + ")"
        }
    }
}
