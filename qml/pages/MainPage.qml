import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"


BasePage {
    property string selectedTab: "expenses"

    HeaderComponent {
        id: header
        headerText: "Баланс"
        selectedTab: parent.selectedTab
    }
}
