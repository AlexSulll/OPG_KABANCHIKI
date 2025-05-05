import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../models" as Models

BasePage {
    id: analyticsPage
    allowedOrientations: Orientation.All
    readonly property color expenseColor: Theme.errorColor
    readonly property color incomeColor: Theme.highlightColor
    property bool isExpense: true
    property int countisCompleted
    property int allGoals
    property color currentColor: isExpense ? expenseColor : incomeColor
    property bool fullscreenGraph: false

    property var operationModel: Models.OperationModel {
        onDataChanged: updateChartData()
        Component.onCompleted: {
            refresh();
            updateChartData();
        }
    }

    property var goalModel: Models.GoalModel {
        onDataChanged: refresh()
        Component.onCompleted: {
            refresh();
            allGoals = getCount()
            countisCompleted = getCountisCompleted();
            console.log("Получена длина ", countisCompleted)
        }
    }

    property var chartCanvas: graphic.children[1].children[0].children[0]
    property var timeSeriesData: []
    property var selectedMonthData: ({})
    property bool showMonthPopup: false
    property bool pulsing: true
    property real pulseSize: 1.0


    function updateChartData() {
        console.log("Updating chart data...");
        var chartData = operationModel.getTimeSeriesData("All");

        if (chartData && chartData.length > 0) {
            // Фильтруем записи с value = 0
            timeSeriesData = chartData.filter(function(item) {
                return item.value > 0;
            });
            console.log("Filtered data points:", timeSeriesData.length);
        } else {
            timeSeriesData = [];
        }

        if (graphic.chartCanvas) {
            graphic.chartCanvas.requestPaint();
        }
    }

    SequentialAnimation {
        running: pulsing
        loops: Animation.Infinite
        NumberAnimation {
            target: analyticsPage
            property: "pulseSize"
            from: 1.0
            to: 1.2
            duration: 800
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: analyticsPage
            property: "pulseSize"
            from: 1.2
            to: 1.0
            duration: 800
            easing.type: Easing.InOutQuad
        }
    }

    Rectangle {
        anchors.fill: parent
    }
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.paddingLarge

            // Карточка с общей статистикой
            BackgroundItem {
                id: fullStaticCard
                width: parent.width
                anchors.left: parent.left
                x: Theme.horizontalPageMargin
                height: Theme.itemSizeExtraLarge * 1.35
                Rectangle {
                    anchors.fill: parent
                    radius: Theme.paddingMedium
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#24224f" }
                        GradientStop { position: 1.0; color: "#1a1a3a" }
                    }
                    border.color: "#24224f"
                    border.width: 4
                }

                Row {
                    anchors.centerIn: parent
                    spacing: Theme.paddingLarge * 2

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.paddingSmall
                        Label {
                            text: qsTr("За время использования\nприложения потрачено")
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeMedium
                        }
                        Label {
                            text: {
                                var total = 0;
                                for (var i = 0; i < timeSeriesData.length; i++) {
                                    total += timeSeriesData[i].value;
                                }
                                return (total/1000).toFixed(1) + "k ₽"
                            }
                            color: Theme.primaryColor
                            font {
                                pixelSize: Theme.fontSizeExtraLarge
                                bold: true
                            }
                        }
                    }

                    Rectangle {
                        width: 2
                        height: parent.height * 0.6
                        color: Theme.rgba(currentColor, 0.5)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.paddingSmall
                        Label {
                            text: qsTr("В среднем вы\nтратили в месяц")
                            color: Theme.secondaryColor
                            font.pixelSize: Theme.fontSizeMedium
                        }
                        Label {
                            text: {
                                var avg = 0;
                                for (var i = 0; i < timeSeriesData.length; i++) {
                                    avg += timeSeriesData[i].value;
                                }
                                return (avg/timeSeriesData.length/1000).toFixed(1) + "k ₽"
                            }
                            color: Theme.primaryColor
                            font {
                                pixelSize: Theme.fontSizeExtraLarge
                                bold: true
                            }
                        }
                    }
                }
            }

            // График
            GraphicContainerComponent {
                id: graphic
                HorizontalScrollDecorator {}
            }

            Item {
                id: summaryInfo
                width: parent.width
                height: Theme.itemSizeMedium * 1.5
                anchors.top: graphic.bottom
                anchors.topMargin: Theme.paddingLarge

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.paddingMedium

                    Row {
                        spacing: Theme.paddingSmall
                        anchors.horizontalCenter: parent.horizontalCenter

                        Label {
                            text: qsTr("Количество операций: ")
                            color: "#24224f"
                            font.pixelSize: Theme.fontSizeMedium
                        }

                        Label {
                            text: timeSeriesData.length
                            color: "#24224f"
                            font {
                                pixelSize: Theme.fontSizeLarge
                                bold: true
                            }
                        }
                    }
                    Row {
                        spacing: Theme.paddingSmall
                        anchors.horizontalCenter: parent.horizontalCenter

                        Label {
                            text: qsTr("Самая популярная категория: ")
                            color: "#24224f"
                            font.pixelSize: Theme.fontSizeMedium
                        }

                        Label {
                            text: "Пусто"
                            color: "#24224f"
                            font {
                                pixelSize: Theme.fontSizeLarge
                                bold: true
                            }
                        }
                    }

                    Row {
                        spacing: Theme.paddingSmall
                        anchors.horizontalCenter: parent.horizontalCenter

                        Label {
                            text: qsTr("Целей достигнуто: ")
                            color: "#24224f"
                            font.pixelSize: Theme.fontSizeMedium
                        }

                        Label {
                            text: countisCompleted+ "/" + allGoals
                            color: "#24224f"
                            font {
                                pixelSize: Theme.fontSizeLarge
                                bold: true
                            }
                        }
                    }
                }
            }
        }
    }


    Rectangle {
        id: monthPopup
        visible: showMonthPopup
        width: parent.width * 0.8
        height: parent.height * 0.6
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#24224f" }
            GradientStop { position: 1.0; color: "#1a1a3a" }
        }
        radius: Theme.paddingLarge
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Column {
            id: column
            width: parent.width - 2*Theme.paddingLarge
            anchors {
                top: parent.top
                topMargin: Theme.paddingLarge
                horizontalCenter: parent.horizontalCenter
            }
            spacing: Theme.paddingMedium

            Label {
                text: selectedMonthData.month+","+selectedMonthData.year || ""
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: (selectedMonthData.value/1000).toFixed(1) + "k ₽"
                color: Theme.primaryColor
                font {
                    pixelSize: Theme.fontSizeHuge
                    bold: true
                }
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: showMonthPopup = false
        }
    }
    Label {
        anchors.centerIn: parent
        visible: !timeSeriesData || timeSeriesData.length === 0
        text: timeSeriesData ? qsTr("No data available") : qsTr("Loading...")
        color: "#24224f"
        font.pixelSize: Theme.fontSizeLarge
    }
}
