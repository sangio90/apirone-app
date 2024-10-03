AP.plate = AP.plate || {};

AP.plate.fields = {
    listRoot: $('#plate-list-root'),
    detailRoot: $('#plate-detail-form')
}

$(document).ready(function(){

	if ( AP.plate.fields.listRoot.length ) {

	    AP.plate.list.init();

	}

	if ( AP.plate.fields.detailRoot.length ) {

	    AP.plate.detail.init();

	}

})

AP.line.list = function() {

	var pub = {}

	var dataSources = {
		items: NM.kendo.dataSource( { url: "/manager/ajax/plates" } )
	}

	var viewModel = kendo.observable({
		rows: dataSources.items,
        
        open: function( event ) {

            var id = event.data.id
            window.open( "/manager/lines/" + id, '_blank').focus();

        },

		print: function( item ) {

            window.open('/manager/lines/print', '_blank');

            return false;
		},


	});

	pub.init = function() {

        console.log("init")

        kendo.bind( AP.line.fields.listRoot, viewModel );

	}	

    return pub;
}();


/*
AP.line.detail = function() {

    var pub = {};

    var roles = [{ id: 'ADM', 'name':  'Admin' },{ 'id': 'COM', 'name': 'Commerciale' }];
    var statusList = [{ 'id': 'ACT', 'name': 'Attivo' },{ 'id': 'DEA', 'name': 'Disattivato' }];
    var data = { 'id': '1', 'name': 'Admin', 'email': 'roberto@marzialetti.com', 'surname': 'Marzialetti', 'role': { 'id': 'ADM', 'name': 'Admin' } };

	var viewModel = kendo.observable({
        roles: roles,
        statusList: statusList,
        detailForm: {
            data: data,
            label: '',
            title: 'Dettaglio ruolo',
            action: 'update'
        },

        edit: function( event ) {
            
            AP.role.fields.item.removeClass('d-none');

            this.set("detailForm.data", event.data );
            this.set("detailForm.title", "Modifica ruolo < " + event.data.email + " >"  );
            this.set("detailForm.action", "update" );

            return false;
		},

        new: function( event ) {

            AP.role.fields.item.removeClass('d-none');

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

        console.log("role:detail:init");

		kendo.bind( AP.role.fields.rootDetail, viewModel )
        
	}	

    return pub;

}();
*/