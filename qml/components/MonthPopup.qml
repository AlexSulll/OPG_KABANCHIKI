import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models" as Models

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
    z: 1000

    property var monthCategories
    property bool show: showMonthPopup
    property var monthData: ({})

    Rectangle {
        id: closeButton
        width: Theme.itemSizeSmall
        height: width
        radius: width/2
        color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
        anchors {
            top: parent.top
            topMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.paddingMedium
        }

        Icon {
            source: "image://theme/icon-m-close"
            anchors.centerIn: parent
            color: Theme.primaryColor
        }

        MouseArea {
            anchors.fill: parent
            onClicked: showMonthPopup = false
        }
    }

    Column {
        id: column
        width: parent.width - 2*Theme.paddingLarge
        height: parent.height
        anchors {
            top: parent.top
            topMargin: Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        spacing: Theme.paddingMedium

        Label {
            text: monthData.month + "," + monthData.year || ""
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeExtraLarge
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Label {
            text: (monthData.value/1000).toFixed(1) + "k ₽"
            color: Theme.primaryColor
            font {
                pixelSize: Theme.fontSizeHuge
                bold: true
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        Repeater {
            model: monthCategories

            Column {
                width: parent.width
                spacing: Theme.paddingSmall

                Label {
                    text: modelData.categoryName
                    color: Theme.primaryColor
                    font.pixelSize: Theme.fontSizeSmall
                }

                Rectangle {
                    width: parent.width
                    height: 40
                    radius: 5
                    color: Theme.rgba(Theme.secondaryColor, 0.1)
                    border.color: Theme.rgba(Theme.secondaryColor, 0.3)
                    border.width: 1

                    Rectangle {
                        width: parent.width * (modelData.value/monthData.value)
                        height: parent.height
                        radius: 5
                        color: {
                            var colors = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A", "#A28DFF"];
                            return colors[index % colors.length];
                        }

                        Row {
                            anchors {
                                fill: parent
                                margins: Theme.paddingSmall
                            }
                            spacing: Theme.paddingMedium

                            Label {
                                text: Math.round((modelData.value/monthData.value*100)) + "%"
                                color: Theme.primaryColor
                                font {
                                    pixelSize: Theme.fontSizeSmall
                                    bold: true
                                }
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Label {
                                text: modelData.value + " ₽"
                                color: Theme.primaryColor
                                font.pixelSize: Theme.fontSizeSmall
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
                
                VerticalScrollDecorator {}
            }
        }
    }
}
