AP.quotation = AP.quotation || {};

AP.quotation.fields = {
    rootList: $("#quotation-list-root"),
    rootDetail: $("#quotation-detail-root")
};

$(document).ready(function (){

	if (AP.quotation.fields.rootList.length) {

		// AP.quotation.list.init();

	}

	if (AP.quotation.fields.rootDetail.length) {

        // console.log("qui");

	    AP.quotation.detail.init();

	}

});

AP.quotation.list = (function () {

	var pub = {};

	pub.init = function () {

        kendo.bind(FW.account.fields.rootList, viewModel);

	};

    return pub;
}());


AP.quotation.detail = (function () {

    var pub = {};

    var roles = [{ id: "ADM", "name":  "Admin" }, { "id": "COM", "name": "Commerciale" }];
    var statusList = [{ "id": "ACT", "name": "Attivo" }, { "id": "DEA", "name": "Disattivato" }];
    var data = { "id": "1", "name": "Roberto", "email": "roberto@marzialetti.com", "surname": "Marzialetti", "role": { "id": "ADM", "name": "Admin" } };

	var viewModel = kendo.observable({
        roles: roles,
        statusList: statusList,
        detailForm: {
            data: data,
            label: "",
            title: "Dettaglio account",
            action: "update"
        },

		print: function (item) {

            window.open("/manager/quotations/print", "_blank");

            return false;
		},


	});

	pub.init = function () {

        console.log("quotation:detail:init");

        var suggest = $("#quotation-detail-form #company-name");

        suggest.kendoAutoComplete({
            dataSource: AP.config.customers,
            dataTextField: "name",
            select: function (event) {
                console.log("event", event);
                var item = event.dataItem;
                // var text = item.text();

                var thisForm = $("#quotation-detail-form");

                thisForm.find("select[name=vatCodeId]").val(item.vatCode);
                thisForm.find("select[name=paymentMethodId]").val(item.paymentMethod);
                thisForm.find("select[name=priceListId]").val(item.priceList);
                thisForm.find("select[name=currencyId]").val(item.currency);

                /* The result can be observed in the DevTools(F12) console of the browser. */
                // console.log(text);
                // Use the selected item or its text
            }

        });

        var autocomplete = suggest.data("kendoAutoComplete");

        // autocomplete.suggest("Apples");

		kendo.bind(AP.quotation.fields.rootDetail, viewModel);

	};

    return pub;

}());


addZone = function () {
    $("#add-zona-modal").modal("show");
    return false;
};

addPlate = function () {
    $("#add-plate-modal").modal("show");
    return false;
};