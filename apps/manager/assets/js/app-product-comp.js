AP.role = AP.role || {};

AP.role.fields = {
    rootList: $('#role-list-root'),
    rootDetail: $('#role-detail-form')
}

$(document).ready(function(){

	if ( AP.role.fields.rootList.length ) {

		//AP.role.list.init();

	}

	if ( AP.role.fields.rootDetail.length ) {

	    AP.role.detail.init();

	}

})


var addComponents = function() {

    $('#list-compoments-modal').modal('show');

}