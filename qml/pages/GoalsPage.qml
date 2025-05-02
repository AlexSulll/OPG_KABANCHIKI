import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

BasePage {
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
                titleColor: "#24224f"
            }

            Button {
                text: "Добавить цель"
                color: "#24224f"
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
