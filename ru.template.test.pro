TARGET = ru.template.test

CONFIG += \
    auroraapp

PKGCONFIG += \

SOURCES += \
    src/main.cpp \

HEADERS +=

DISTFILES += \
    qml/components/CategoryDelegate.qml \
    qml/components/MainCardComponent.qml \
    qml/models/DateFilterModel.qml \
    qml/models/SectorsModel.qml \
    qml/models/SideDrawer.qml \
    qml/models/SideMenuModel.qml \
    qml/pages/BasePage.qml \
    rpm/ru.template.test.spec \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += auroraapp_i18n

TRANSLATIONS += \
    translations/ru.template.test.ts \
    translations/ru.template.test-ru.ts \
