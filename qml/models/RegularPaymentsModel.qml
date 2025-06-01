import QtQuick 2.0
import "../services" as Services

QtObject {
    id: model

    property var payments: []
    property var regularPaymentsService: Services.RegularPaymentsService {}

    signal paymentsUpdated

    function loadPayments() {
        payments = regularPaymentsService.getPayments();
        paymentsUpdated();
    }

    function addPayment(payment) {
        var result = regularPaymentsService.addPayment(payment);
        if (result)
            loadPayments();
        return result;
    }

    function updatePayment(payment) {
        var result = regularPaymentsService.updatePayment(payment);
        if (result)
            loadPayments();
        return result;
    }

    function calculateNextDate(fromDate, frequency) {
        return regularPaymentsService.calculateNextDate(fromDate, frequency);
    }

    function removePayment(id) {
        var result = regularPaymentsService.removePayment(id);
        if (result)
            loadPayments();
        return result;
    }
}
