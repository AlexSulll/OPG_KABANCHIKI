import QtQuick 2.0
import "../services"

ListModel {
    id: goalModel
    objectName: "GoalModel"

    property var service: GoalService {
        id: goalService
        Component.onCompleted: initialize()
    }

    function refresh() {
        clear()
        var goals = goalService.getGoals()
        goals.forEach(function(goal) {
            append({
                id: goal.id,
                title: goal.title,
                targetAmount: goal.targetAmount,
                currentAmount: goal.currentAmount,
                startDate: goal.startDate,
                endDate: goal.endDate
            })
        })
    }

    function addGoal(goal) {
        goalService.addGoal(goal)
        refresh()
    }

    function updateGoal(goal) {
        goalService.updateGoal(goal)
        refresh()
    }
}
