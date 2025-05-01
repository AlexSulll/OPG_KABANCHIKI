import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: goalsPage

    property var goalModel

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: "Финансовые цели"
            }

            Button {
                text: "Добавить цель"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: pageStack.push(addGoalComponent)
            }

            Repeater {
                model: goalModel
                delegate: GoalItemDelegate {}
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
