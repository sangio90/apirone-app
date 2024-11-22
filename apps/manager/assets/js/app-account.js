AP.account = AP.account || {};

AP.account.fields = {
    listRoot: $("#account-list-root"),
    detailRoot: $("#account-detail-modal"),
    detailForm: $("#account-detail-form"),
    searchListForm: $("#account-grid-search-form")
}

$(document).ready(function(){

	if ( AP.account.fields.listRoot.length ) {

	    AP.account.list.init();

	}

	if ( AP.account.fields.detailRoot.length ) {

	    AP.account.detail.init();

	}

})

AP.account.list = function() {

	var pub = {}

    var detailApp = AP.account.detail;

	var dataSources = {
		items: NM.kendo.dataSource( { url: "/manager/ajax/accounts" } )
	}

	var viewModel = kendo.observable({
		rows: dataSources.items,

        getCreatedAt: function( event ) {

            return NM.kendo.formatDate( event.createdAt );
            
		},
        
        search: function( event ) {

            console.log("search")

            var thisForm = AP.account.fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params )

            return false;

        },

        new: function( event ) {

            console.log("detailApp", detailApp)

            var onSave = function() {
                viewModel.get("rows").read();
            }

            detailApp.new( { onSave: onSave } );

            return false;

        },

		print: function( item ) {

            window.open('/manager/lines/print', '_blank');

            return false;
		},

        delete: function( event ) {

			var status = $("#status-delete");
			var checks = $('#account-grid').find("[name=selected]:checked");

			if ( checks.length ) {

				var values = [];

				checks.each(function(){
					values.push( $(this).val() )
				}) 

				var ids = values.toString();

				NM.util.ajax({ 
					method: "DELETE", 
					url: "/manager/ajax/accounts",
					data: ids,
					callback: {
						done: function( xhr ) {

							if( xhr.data.payload.hasOwnProperty("errors") ) {
								AP.widget.notify( "error", "Non riesco a cancellare tutti i valori" )
							} else {
								AP.widget.notify( "success", "Cancellazione avvenuta con successo" )
							}

							var id = viewModel.get("detailForm.data.id");
							console.log("id", id);

							viewModel.rows.read()
							
						}
					}
				})

			} else {

				NM.util.autoHideMessage( status, "<span class='red'>Selezionare almeno un valore</span>" );

			}            

        },        

	});

	pub.init = function() {

        console.log("account:init")

        kendo.bind( AP.account.fields.listRoot, viewModel );

	}	

    return pub;
}();


AP.account.detail = function() {

    var pub = {};

	var defaultDetailForm = {
		data: {
			id: "",
			code: "",
			name: "",
			category: {
                id: ""
            },
			thickness: {
                id: ""
            },
			status: {
				id: "ACT"
			}
		},
		
        statuses: AP.page.statuses,
        roles: AP.page.roles,
        langs: AP.page.langs,

		title: "Carica account"
	};

	var viewModel = kendo.observable({
        detailForm: defaultDetailForm,


		resetForm: function () {

            var detailForm = AP.account.fields.detailForm;

            var validator = detailForm.validate();
            validator.resetForm();

            detailForm.find(".status").html("");

			viewModel.set("detailForm", defaultDetailForm);
		},


        edit: function( event ) {
            
            this.set("detailForm.data", event.data );
            this.set("detailForm.title", "Modifica account < " + event.data.email + " >"  );
            this.set("detailForm.action", "update" );

            return false;
		},

        getCreatedAt: function( event ) {

            return FW.kendo.formatDate( event.createdAt );
            
		},

        new: function( event ) {

            viewModel.resetForm()

            return false;
		},


		print: function( item ) {

            window.open('/manager/account/print', '_blank');

            return false;
		},


	});    

	pub.init = function() {

        console.log("account:detail:init");

		kendo.bind( AP.account.fields.detailRoot, viewModel )
        
	}	

    return pub;

}();
