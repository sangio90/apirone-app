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

var addProducts = function() {

    $('#list-products-modal').modal('show');

}

var getCompValues = function( compId ) {


	console.log("getCompValues:id", compId)

	var select = $('#list-values');
	select.find('option').remove();

	for ( comp of components ) {

		if ( comp.id == compId ) {

			for ( var value of comp.values ) {

				select.append('<option value="foo">' + value.name + '</option>')

			}

		}

	}

}