AP.account = AP.account || {};

AP.product.fields = {
    rootList: $('#product-list-root'),
    rootDetail: $('#product-detail-form')
}

$(document).ready(function(){

	if ( AP.product.fields.rootList.length ) {

		//AP.product.list.init();

	}

	if ( AP.product.fields.rootDetail.length ) {

	    AP.product.detail.init();

	}

})

AP.product.list = function() {

	var pub = {}

	pub.init = function() {

        kendo.bind( FW.product.fields.rootList, viewModel );

	}	

    return pub;
}();


AP.product.detail = function() {

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
            
            FW.product.fields.item.removeClass('d-none');

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

            FW.product.fields.item.removeClass('d-none');

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

		kendo.bind( AP.product.fields.rootDetail, viewModel )
        
	}	

    return pub;

}();
