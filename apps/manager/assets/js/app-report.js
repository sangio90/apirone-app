AP.report = AP.report || {};

AP.report.fields = {
    rootList: $("#report-list-root"),
    rootDetail: $("#report-detail-form")
};

$(document).ready(function (){

	if (AP.report.fields.rootList.length) {

	    AP.report.list.init();

	}

	if (AP.report.fields.rootDetail.length) {

	    AP.report.detail.init();

	}

});

AP.report.list = (function () {

	var pub = {};

	var dataSources = {
		items: NM.kendo.dataSource({ url: "/manager/ajax/reports" })
	};

	var viewModel = kendo.observable({
		rows: dataSources.items,
        detailForm: {
        },

		deleteAll: function (item) {
		},

		save: function (item) {
		},


		saveAll: function (item) {
		},

        edit: function (event) {

            var thisUrl = "/manager/reports/" + event.data.id;
            window.open(thisUrl, "_blank").focus();
		},

        new: function (event) {
		},

		print: function (item) {
		},


	});

	pub.init = function () {

        kendo.bind(AP.report.fields.rootList, viewModel);

	};

    return pub;
}());


AP.report.detail = (function () {

    var pub = {};

	var viewModel = kendo.observable({
        detailForm: {
            data: {},
            label: "",
            title: "Dettaglio report",
            action: "update"
        },

        edit: function (event) {
            return false;
		},

        new: function (event) {

            return false;
		},


		print: function (item) {

            window.open("/manager/reports/print", "_blank");

            return false;
		},


	});

	pub.init = function () {

        console.log("report:detail:init");

		kendo.bind(AP.report.fields.rootDetail, viewModel);

	};

    return pub;

}());
