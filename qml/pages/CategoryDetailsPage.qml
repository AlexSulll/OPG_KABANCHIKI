import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../models" as Models

Page {
    id: categorydetailspage
    objectName: "CategoryDetailsPage"

    property var categoryModel
    property int categoryId
    property int action
    property string currentPeriod: "All"
    property var operationModel
    property var dateFilterModel

    property ListModel groupedModel: ListModel {}

    Models.OperationModel {
        id: operationModel
    }

    Component.onCompleted: {
        if (operationModel && dateFilterModel) {
            operationModel.dateFilterModel = dateFilterModel;
            operationModel.loadOperationsByCategoryAndPeriod(categoryId, action, currentPeriod);
            groupOperationsByDate();
        }
    }

    Models.CategoryModel {
        id: categoryModel
        Component.onCompleted: {
            loadAllCategories();
        }
    }

    HeaderCategoryComponent {
        id: header
        fontSize: Theme.fontSizeExtraLarge * 1.2
        color: "transparent"
        headerText: {
            if (categoryModel) {
                var category = categoryModel.getCategoryById(categoryId);
                return category ? category.nameCategory : "Детали категории";
            }
        }
    }

    SilicaListView {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: Theme.paddingMedium
        }
        model: groupedModel
        spacing: Theme.paddingSmall
        clip: true

        delegate: Column {
            width: parent.width
            spacing: Theme.paddingSmall

            readonly property var ops: model && model.operations ? model.operations : []

            SectionHeader {
                text: model.date
                font.pixelSize: Theme.fontSizeMedium
            }

            Repeater {
                model: ops

                delegate: ListItem {
                    width: parent.width
                    contentHeight: Theme.itemSizeMedium

                    property var categoryData: categoryModel.getCategoryById(model.categoryId)

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.paddingMedium
                        color: Theme.rgba("#24224f", 0.9)

                        Row {
                            anchors.fill: parent
                            anchors.margins: Theme.paddingMedium
                            spacing: Theme.paddingMedium

                            Image {
                                id: icon
                                asynchronous: true
                                width: Theme.iconSizeMedium
                                height: width
                                anchors.verticalCenter: parent.verticalCenter
                                source: categoryData ? categoryData.pathToIcon : ""
                                sourceSize: Qt.size(width, height)
                                fillMode: Image.PreserveAspectFit
                            }

                            Column {
                                width: parent.width * 0.6
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: icon.right
                                anchors.leftMargin: Theme.paddingLarge
                                spacing: Theme.paddingSmall

                                Label {
                                    text: categoryData ? categoryData.nameCategory : "Без категории"
                                    color: Theme.primaryColor
                                    font.pixelSize: Theme.fontSizeLarge
                                    truncationMode: TruncationMode.Fade
                                }
                            }

                            Label {
                                id: amountLabel
                                width: Math.min(implicitWidth, parent.width * 0.35)
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                    rightMargin: Theme.paddingSmall
                                }
                                horizontalAlignment: Text.AlignRight
                                text: isNaN(model.amount) ? "0 ₽" : Number(model.amount).toLocaleString(Qt.locale(), 'f', 0) + " ₽"
                                color: model.action === 0 ? "#FF6384" : Theme.highlightColor
                                font {
                                    pixelSize: Theme.fontSizeLarge
                                    family: Theme.fontFamilyHeading
                                    bold: true
                                }
                                elide: Text.ElideRight
                            }
                        }
                    }

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("../pages/OperationDetailsPage.qml"), {
                            operationId: model.id,
                            operationModel: operationModel,
                            categoryModel: categoryModel
                        });
                    }
                }
            }
        }

        VerticalScrollDecorator {}
    }

    function groupOperationsByDate() {
        groupedModel.clear();
        var operationsByDate = {};

        for (var i = 0; i < operationModel.count; i++) {
            var op = operationModel.get(i);

            if (op.categoryId !== categoryId || op.action !== action)
                continue;
            var dateParts = op.date.split('.');

            if (dateParts.length !== 3)
                continue;
            var jsDate = new Date(dateParts[2], dateParts[1] - 1, dateParts[0]);

            if (isNaN(jsDate.getTime()))
                continue;
            var dateKey = Qt.formatDate(jsDate, "yyyy-MM-dd");

            if (!operationsByDate[dateKey]) {
                operationsByDate[dateKey] = [];
            }

            operationsByDate[dateKey].push(op);
        }

        var sortedDates = Object.keys(operationsByDate).sort().reverse();

        sortedDates.forEach(function (dateKey) {
            var opsArray = operationsByDate[dateKey] || [];
            groupedModel.append({
                date: Qt.formatDate(new Date(dateKey), "dd.MM.yyyy"),
                operations: opsArray.slice()
            });
        });
    }
}
