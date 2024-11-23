AP.role = AP.role || {};

AP.role.fields = {
    rootList: $("#role-list-root"),
    rootDetail: $("#role-detail-form")
};

$(document).ready(function (){

	if (AP.role.fields.rootList.length) {

		// AP.role.list.init();

	}

	if (AP.role.fields.rootDetail.length) {

	    AP.role.detail.init();

	}

});

AP.role.list = (function () {

	var pub = {};

	pub.init = function () {

        kendo.bind(AP.role.fields.rootList, viewModel);

	};

    return pub;
}());


AP.role.detail = (function () {

    var pub = {};

    var roles = [{ id: "ADM", "name":  "Admin" }, { "id": "COM", "name": "Commerciale" }];
    var statusList = [{ "id": "ACT", "name": "Attivo" }, { "id": "DEA", "name": "Disattivato" }];
    var data = { "id": "1", "name": "Admin", "email": "roberto@marzialetti.com", "surname": "Marzialetti", "role": { "id": "ADM", "name": "Admin" } };

	var viewModel = kendo.observable({
        roles: roles,
        statusList: statusList,
        detailForm: {
            data: data,
            label: "",
            title: "Dettaglio ruolo",
            action: "update"
        },

        edit: function (event) {

            AP.role.fields.item.removeClass("d-none");

            this.set("detailForm.data", event.data);
            this.set("detailForm.title", "Modifica ruolo < " + event.data.email + " >");
            this.set("detailForm.action", "update");

            return false;
		},

        new: function (event) {

            AP.role.fields.item.removeClass("d-none");

            var data = { role: { id: "ADM" }, status: { id: "ACT" } };

            this.set("detailForm.data", data);
            this.set("detailForm.title", "Carica account");
            this.set("detailForm.action", "create");

            return false;
		},


		print: function (item) {

            window.open("/manager/account/print", "_blank");

            return false;
		},


	});

	pub.init = function () {

        console.log("role:detail:init");

		kendo.bind(AP.role.fields.rootDetail, viewModel);

	};

    return pub;

}());
