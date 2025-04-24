/*
  Твой бургер
*/
import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models"

Item {
    id: sideDrawer
    anchors.fill: parent
    visible: false

    property int action: 0
    property bool opened: false

    SideMenuModel {
        id: menuModel
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.rgba(0, 0, 0, 0.5)
        opacity: sideDrawer.opened ? 1 : 0

        MouseArea {
            anchors.fill: parent
            onClicked: sideDrawer.close()
        }

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    Rectangle {
        id: drawerContent
        width: parent.width * 0.75
        height: parent.height
        x: -width
        z: 1000
        color: "#191546"

        Column {
            width: parent.width
            spacing: Theme.paddingMedium

            Item {
                width: parent.width
                height: Theme.itemSizeLarge
            }

            Repeater {
                model: menuModel

                delegate: BackgroundItem {
                    width: parent.width
                    height: Theme.itemSizeLarge

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.horizontalPageMargin
                        spacing: Theme.paddingMedium

                        Icon {
                            source: "image://theme/" + icon
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Label {
                            text: model.text
                            anchors.verticalCenter: parent.verticalCenter
                            color: pressed ? Theme.highlightColor : Theme.primaryColor
                        }
                    }

                    onClicked: {
                        sideDrawer.close();
                        if (page === "../pages/OperationPage.qml") {
                            pageStack.push(Qt.resolvedUrl(page));
                        }

                        if (page === "../pages/CategoryPage.qml") {
                            pageStack.push(Qt.resolvedUrl("../pages/CategoryPage.qml"), {
                                    categoryModel: categoryModel,
                                    action: 0 // или 1, в зависимости от контекста
                            });
                        }

                        /*
                            Тут надо доработать логику - скорее всего через стек
                            чтобы при нахождении на целевой станицы и перехода на неё же
                            (сейчас через if обрабатывается только MainPage)
                            не было лишней прокрутки - убери условие - увидишь
                        */
                    }
                }
            }
        }
    }

    function toggle() {
        if (opened) {
            close();
        } else {
            open();
        }
    }

    function open() {
        opened = true;
        sideDrawer.visible = true;
        openAnimation.start();
    }

    function close() {
        opened = false;
        closeAnimation.start();
    }

    SequentialAnimation {
        id: openAnimation
        NumberAnimation {
            target: drawerContent
            property: "x"
            to: 0
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    SequentialAnimation {
        id: closeAnimation
        NumberAnimation {
            target: drawerContent
            property: "x"
            to: -drawerContent.width
            duration: 250
            easing.type: Easing.OutCubic
        }
        ScriptAction {
            script: sideDrawer.visible = false
        }
    }
}
