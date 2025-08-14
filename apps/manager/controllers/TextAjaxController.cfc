component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var dm     = getDataMapper();

		var params = paramsFromUrl();

		var rows = super.fire( "text.search", params );

		for ( var obj in rows.getData() ) {
			var row = dm.convert( obj, "Text", true );

			row[ "entity" ] = "generale";

			data.add( row );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );

		result.setData( data );

		event.setValue( "result", result );
	}

	// all texts by entity
	function all( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var dm     = getDataMapper();

		var text = super.fire( "text.get", [ rc.id ] );

		var rows = super.fire( "text.list", { entity = text.getEntity() } );

		for ( var row in rows ) {
			var bean = dm.convert( row, "Text", true );

			data.add( bean );
		}

		result.setData( data );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var dm     = getDataMapper();

		var obj = super.fire( "text.get", [ rc.id ] );

		var bean = dm.convert( obj, "Text", true );

		result.setData( bean );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result = super.getResult();
		var attr   = super.bean( "Attribute" );

		var text   = super.bean( "Text" );
		var lang   = super.bean( "Lang" );
		var status = super.bean( "Status" );

		var thisId    = "";
		var messageId = "";
		var texts     = [];

		var json = DeserializeJSON( GetHTTPRequestData().content );

		var textItem = json.data.textItem;

		text.setId( textItem.id )
		text.setName( textItem.name )
		text.setLang( lang.setId( mainText.lang.id ) );

		texts.add( text );

		attr.setId( json.data.id );
		attr.setTexts( texts );
		attr.setStatus( status.setId( json.data.status.id ) );

		if ( json.action == "create" ) {
			messageId = "attribute.created";
			thisId    = super.fire( "attribute.create", [ attr ] )
		} else {
			messageId = "attribute.updated";
			thisId    = super.fire( "attribute.update", [ attr ] )
		}

		var message = completeMessage( messageId );

		result.setData( message, { payload = { id = thisId } } );

		event.setValue( "result", result );
	}

	private function getEntityName( id ){
		// TODO: consider to move into DBFields.json

		var result = "";

		switch ( arguments.id ) {
			case "attribute.id":
				WriteOutput( "I like apples!" );
				result = "Attributo";
				break;
			case "attributeValue.id":
				result = "Valore attributo";
				break;
			case "productCategory.id":
				result = "Categoria prodotto";
				break;
			case "finish.id":
				result = "Finitura";
				break;
			case "model.id":
				result = "Dimensione";
				break;
			case "product.id":
				result = "Prodotto";
				break;
			case "rawValue.id":
				result = "Valore base";
				break;
			default:
				result = "** Entity not found";
				break;
		}

		return result;
	}

}
