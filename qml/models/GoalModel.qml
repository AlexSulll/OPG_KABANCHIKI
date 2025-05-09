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
                isCompleted: goal.isCompleted,
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

    function getCountisCompleted() {
        var completedGoals = goalService.getCountisCompleted();
        
        if (Array.isArray(completedGoals)) {
            return completedGoals.length;
        }
        
        return 0;
    }

    function getCount() {
        var completedGoals = goalService.getGoals();
        
        if (Array.isArray(completedGoals)) {
            return completedGoals.length;
        }
        
        return 0;
    }

    function removeGoal(goalId) {
        goalService.deleteGoal(goalId)
        pageStack.replaceAbove(null, Qt.resolvedUrl("../pages/MainPage.qml"))
    }
}
