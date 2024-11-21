AP.account = AP.account || {};

AP.account.fields = {
    listRoot: $('#account-list-root'),
    detailRoot: $('#account-detail-form')
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

	});

	pub.init = function() {

        console.log("account:init")

        kendo.bind( AP.account.fields.listRoot, viewModel );

	}	

    return pub;
}();


AP.account.detail = function() {

    var pub = {};

    var roles = [{ id: 'ADM', 'name':  'Admin' },{ 'id': 'COM', 'name': 'Commerciale' }];
    var statusList = [{ 'id': 'ACT', 'name': 'Attivo' },{ 'id': 'DEA', 'name': 'Disattivato' }];
    var data = { 'id': '1', 'name': 'Roberto', 'email': 'roberto@marzialetti.com', 'surname': 'Marzialetti', 'role': { 'id': 'ADM', 'name': 'Admin' } };

	var viewModel = kendo.observable({
        roles: roles,
        statusList: statusList,
        detailForm: {
            data: data,
            label: '',
            title: 'Dettaglio account',
            action: 'update'
        },

        edit: function( event ) {
            
            FW.account.fields.item.removeClass('d-none');

            this.set("detailForm.data", event.data );
            this.set("detailForm.title", "Modifica account < " + event.data.email + " >"  );
            this.set("detailForm.action", "update" );

            return false;
		},

        setRole: function( event ) {

            console.log("event", event.currentTarget);

            var value = $(event.currentTarget).val();

            console.log("event:value", value);

            if (value == 'ADM') {
                $('#list-role-admin').show()
                $('#list-role-commercial').hide();
            }
            
            if (value == 'COM') {
                $('#list-role-admin').hide()
                $('#list-role-commercial').show();
            }

            /*
            this.set("detailForm.data", event.data );
            this.set("detailForm.title", "Modifica account < " + event.data.email + " >"  );
            this.set("detailForm.action", "update" );
            */

            return false;
		},

        new: function( event ) {

            FW.account.fields.item.removeClass('d-none');

            var data = { role: { id: 'ADM' }, status: { id: 'ACT' } };

            this.set("detailForm.data", data );
            this.set("detailForm.title", "Carica account" );
            this.set("detailForm.action", "create" );

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
