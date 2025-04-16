TARGET = ru.template.WebBudget

CONFIG += \
    auroraapp

PKGCONFIG += \

SOURCES += \
    src/main.cpp \

HEADERS += \

DISTFILES += \
    qml/models/CategoryModel.qml \
    qml/models/OperationModel.qml \
    qml/services/ExpenseService.qml \
    qml/services/RevenueService.qml \
    rpm/ru.template.WebBudget.spec \

AURORAAPP_ICONS = 86x86 108x108 128x128 172x172

CONFIG += auroraapp_i18n

TRANSLATIONS += \
    translations/ru.template.WebBudget.ts \
    translations/ru.template.WebBudget-ru.ts \
