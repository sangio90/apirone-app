AP.quotation = AP.quotation || {};

AP.quotation.fields = {
    rootList: $('#account-list-root'),
    rootDetail: $('#account-detail-form')
}

$(document).ready(function(){

	if ( AP.account.fields.rootList.length ) {

		//AP.account.list.init();

	}

	if ( AP.account.fields.rootDetail.length ) {

	    AP.account.detail.init();

	}

})

AP.quotation.list = function() {

	var pub = {}

    /*
	var dataSources = {
		items: FW.kendo.dataSource( { url: "/manager/ajax/account" } )
	}
    */

    /*
	var viewModel = kendo.observable({
		rows: dataSources.items,
        roles: FW.data.roles,
        statusList: FW.data.statusList,
        detailForm: {
            data: {},
            label: '',
            title: '',
            action: 'update'
        },

		deleteAll: function( item ) {

            FW.account.fields.gridForm.find( "input[name=selected]" );

            var selected = FW.account.fields.gridForm.find( "input[name=selected]:checked" );

            if ( selected.length ) {

                FW.utils.ajax( {
                    method: "POST",
                    url: "/manager/ajax/option/remove-all",
                    data: selected.serialize(),
                    callback: {
                        done: function() {
                            FW.widget.notify( "success", "Dati cancellati con successo" );
                            dataSources.items.read();
                        }
                    }
                } )

            } else {
                
                FW.widget.notify( "warning", "Seleziona almeno un account" );

            }
            
            return false;
		},

		save: function( item ) {

            var valid = FW.account.fields.detailForm.valid();

            if ( valid ) {

                //var data = FW.account.fields.detailForm.serialize();
                var data = JSON.stringify( this.detailForm );

                FW.utils.ajax( {
                    method: "POST",
                    url: "/manager/ajax/option/save",
                    data: data,
                    callback: {
                        done: function() {
                            FW.widget.notify( 'success', "Dati salvati con successo" );
                            dataSources.items.read();
                        }
                    }
                } )
            
            }
            
            return false;
		},

		
		saveAll: function( item ) {

            var valid = FW.account.fields.gridForm.valid();

            if ( valid ) {

                var data = JSON.stringify( this.rows.data() );

                FW.utils.ajax( {
                    method: "POST",
                    url: "/manager/ajax/option/save-all",
                    data: data,
                    callback: {
                        done: function() {
                            FW.widget.notify( 'success', "Dati salvati con successo" );
                            dataSources.items.read();
                        }
                    }
                    
                } )
            
            }
            
            return false;
		},

        edit: function( event ) {
            
            FW.account.fields.item.removeClass('d-none');

            this.set("detailForm.data", event.data );
            this.set("detailForm.title", "Modifica account < " + event.data.email + " >"  );
            this.set("detailForm.action", "update" );

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
    */

	pub.init = function() {

        kendo.bind( FW.account.fields.rootList, viewModel );

	}	

    return pub;
}();


AP.quotation.detail = function() {

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

            return false;
		},

        new: function( event ) {

            FW.account.fields.item.removeClass('d-none');

            var data = { role: { id: 'ADM' }, status: { id: 'ACT' } };

            this.set("detailForm.data", data );
            this.set("detailForm.title", "Carica preventivo" );
            this.set("detailForm.action", "create" );

            return false;
		},


		print: function( item ) {

            window.open('/manager/quotations/print', '_blank');

            return false;
		},


	});    

	pub.init = function() {

        console.log("quotation:detail:init");

		kendo.bind( AP.quotation.fields.rootDetail, viewModel )
        
	}	

    return pub;

}();
