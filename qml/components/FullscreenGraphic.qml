import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    id: fullscreenGraphPage

    allowedOrientations: Orientation.Landscape
    backgroundColor: "white"

    property var timeSeriesData
    property var selectedMonthData
    property real scaleFactor: 0.9

    Behavior on scaleFactor { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

    Component.onCompleted: scaleFactor = 1.0

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: Math.max(parent.width, timeSeriesData ? timeSeriesData.length * 150 : 0)
        contentHeight: parent.height
        clip: true

        Item {
            id: container
            width: Math.max(parent.width, timeSeriesData ? timeSeriesData.length * 150 : 0)
            height: parent.height
            scale: fullscreenGraphPage.scaleFactor
            transformOrigin: Item.Center

            GraphicContainerComponent {
                id: graphicComponent
                width: parent.width * 0.93
                height: parent.height - Theme.paddingLarge * 2
                anchors {
                    centerIn: parent
                    verticalCenterOffset: -Theme.paddingMedium
                }

                pulseSize: 1.1
                pulseOpacity: 0.4

                Canvas {
                    id: chartCanvas
                    anchors {
                        fill: parent
                        margins: Theme.paddingMedium
                    }

                    property var highlightedPoint: -1

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();

                        if (!timeSeriesData || timeSeriesData.length === 0) return;

                        var maxValue = Math.max(
                            10000,
                            Math.max.apply(null, timeSeriesData.map(function(d) {
                                return Math.max(d.value, d.target || 0);
                            }))
                        );

                        var minStep = 150;
                        var availableWidth = Math.max(width - 80, timeSeriesData.length * minStep);
                        var xStep = timeSeriesData.length > 1 ? availableWidth / (timeSeriesData.length - 1) : 0;

                        var chartBottom = height - 80;
                        var chartTop = 70;

                        var points = [];
                        for (var i = 0; i < timeSeriesData.length; i++) {
                            var x = timeSeriesData.length > 1 ? 40 + i * xStep : width / 2;
                            var y = chartBottom - ((timeSeriesData[i].value || 0.0001) / maxValue * (chartBottom - chartTop));
                            points.push({x: x, y: y});
                        }
                    }
                }
            }

            VerticalScrollDecorator {}
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
