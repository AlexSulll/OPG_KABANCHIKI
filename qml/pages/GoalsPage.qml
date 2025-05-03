import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: goalsPage

    property var goalModel

    Component.onCompleted: {
        goalModel.refresh();
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: "Финансовые цели"
                titleColor: Theme.primaryColor
            }

            Repeater {
                model: goalModel
                delegate: GoalItemDelegate {}
            }
            Button {
                text: "Добавить цель"
                color: Theme.secondaryColor
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
