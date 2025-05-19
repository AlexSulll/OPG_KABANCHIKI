import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: goalsPage

    property var goalModel

    Component.onCompleted: {
        goalModel.refresh();
    }

    HeaderCategoryComponent {
        id: header
        fontSize: Theme.fontSizeExtraLarge * 1.2
        color: "transparent"
        headerText: "Финансовые цели"
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
            anchors.top: header.bottom

            Repeater {
                model: goalModel
                delegate: GoalItemDelegate {}
            }

            Button {
                text: "Добавить цель"
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: pageStack.push(addGoalComponent)
            }
        }
    }

    Component {
        id: addGoalComponent
        AddGoalPage {
            goalModel: goalsPage.goalModel
        }
    }
}
