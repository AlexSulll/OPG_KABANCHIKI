import QtQuick 2.0
import QtQuick.LocalStorage 2.0

QtObject {
    function getExportFolder() {
        // Возвращает путь к папке для экспорта
        return StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + "/WebBudgetExport"
    }

    function clearExportFolder() {
        var folder = getExportFolder()
        var dir = Qt.createQmlObject('import QtQuick 2.0; import Qt.labs.folderlistmodel 2.1; FolderListModel {}', this)
        dir.folder = "file://" + folder
        dir.showFiles = true

        for (var i = 0; i < dir.count; i++) {
            var filePath = dir.get(i, "filePath")
            Qt.callLater(function() { Qt.deleteFile(filePath) })
        }

        return true
    }

    function checkStorage() {
        return {
            hasSpace: true, // Реализуйте проверку свободного места
            freeSpace: 0
        }
    }
}
