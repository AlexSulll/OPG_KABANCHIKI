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
    qml/components/FullscreenGraph.qml \
    qml/components/FullscreenGraphic.qml \
    qml/components/GoalItemDelegate.qml \
    qml/components/GraphicContainerComponent.qml \
    qml/components/HeaderCategoryComponent.qml \
    qml/components/HeaderComponent.qml \
    qml/components/MainCardComponent.qml \
    qml/components/OperationDelegate.qml \
    qml/components/SideDrawerComponent.qml \
    qml/components/TimeSeriesGraph.qml \
    qml/models/CategoryModel.qml \
    qml/models/DateFilterModel.qml \
    qml/models/GoalModel.qml \
    qml/models/OperationModel.qml \
    qml/models/SectorsModel.qml \
    qml/models/SideMenuModel.qml \
    qml/pages/AddCategoryPage.qml \
    qml/pages/AddGoalPage.qml \
    qml/pages/AnalyticsPage.qml \
    qml/pages/BasePage.qml \
    qml/pages/CategoryDetailsPage.qml \
    qml/pages/EditGoalPage.qml \
    qml/pages/GoalsPage.qml \
    qml/pages/LimitCategoryPage.qml \
    qml/pages/OperationDetailsPage.qml \
    qml/pages/OperationPage.qml \
    qml/services/CategoryService.qml \
    qml/services/GoalService.qml \
    qml/services/OperationService.qml \
    rpm/ru.template.WebBudget.spec \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += auroraapp_i18n

TRANSLATIONS += \
    translations/ru.template.WebBudget.ts \
    translations/ru.template.WebBudget-ru.ts \
