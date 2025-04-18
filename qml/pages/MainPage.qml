import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"
import "../services" as Services
import "../models" as Models

BasePage {
    id: mainpage
    property string selectedTab: "expenses"

    HeaderComponent {
        id: header
        headerText: "Баланс"
        selectedTab: parent.selectedTab
    }
}
