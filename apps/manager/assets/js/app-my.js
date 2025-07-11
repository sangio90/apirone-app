AP.my = AP.my || {};
AP.fields.my = AP.fields.my || {};

AP.fields.my.detail = {
    detailRoot: $("#my-account-root"),
    pwdForm: $("#my-account-detail-form"),
};


$(document).ready(function (){

	if ( AP.fields.my.detail.detailRoot.length ) {

	    AP.my.detail.init();

	}

});


AP.my.detail = (function () {

    var pub = {};
    var fields = AP.fields.my.detail;

	var viewModel = kendo.observable({

		resetForm: function () {
		},

        save: function (event) {

			var pwdForm = fields.pwdForm;
			var status = pwdForm.find(".status");

			if(pwdForm.valid()) {

				status.html("<img src=/assets/main/img/ajax-loading.svg width=20 height=20>");

				NM.util.ajax({
					method: "POST",
					url: "/manager/ajax/change-pwd",
					data: pwdForm.serialize(),
					callback: {
						done: function (xhr) {

							console.log("xhr.data", xhr.data)

							if(xhr.data.payload.hasOwnProperty("errors")) {
								status.html("<span class='red'>" + xhr.data.message.text + "</span>")
							} else {
								status.html("<span class='green'>" + xhr.data.message.text + "</span>")
							}

							//NM.util.autoHideMessage(status, "<span class='green'>Password modificata</span>");

						}
					}
				});

			}

            return false;

        },

	});


	pub.init = function () {

        kendo.bind( fields.detailRoot, viewModel );

		var pwdForm = fields.pwdForm;

		pwdForm.validate({
			onfocusout: function (element) {
				$(element).valid();
			}
		});

	};

    return pub;
}());
