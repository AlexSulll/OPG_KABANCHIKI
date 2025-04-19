TARGET = ru.template.WebBudget

CONFIG += \
    auroraapp

PKGCONFIG += \

SOURCES += \
    src/main.cpp \

HEADERS += \

DISTFILES += \
    qml/components/CategoryDelegate.qml \
    qml/components/CategoryDisplay.qml \
    qml/components/HeaderComponent.qml \
    qml/components/OperationDelegate.qml \
    qml/components/SideDrawerComponent.qml \
    qml/models/CategoryModel.qml \
    qml/models/OperationModel.qml \
    qml/models/SideMenuModel.qml \
    qml/pages/AddCategoryPage.qml \
    qml/pages/BasePage.qml \
    qml/pages/OperationPage.qml \
    qml/services/CategoryService.qml \
    qml/services/OperationService.qml \
    rpm/ru.template.WebBudget.spec \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += auroraapp_i18n

TRANSLATIONS += \
    translations/ru.template.WebBudget.ts \
    translations/ru.template.WebBudget-ru.ts \
