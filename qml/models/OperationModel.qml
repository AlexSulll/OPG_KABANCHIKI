/*
  OperationModel.qml
*/

import QtQuick 2.0

ListModel {
    id: operationModel
    objectName: "OperationModel"

    function load(operations) {
        clear()
        for (var i = 0; i < operations.length; ++i) {
            append(operations[i])
        }
    }

    function add(operation) {
        append(operation)
    }
}
