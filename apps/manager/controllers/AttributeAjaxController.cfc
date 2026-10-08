component extends="com.apirone.core.controller.AbsController" {

	function get( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var mm     = super.getMementify();

		var obj = super.fire( "attribute.get", [ rc.id ] );

		var attr = mm.convert( obj, "list" );

		result.setData( attr );

		event.setValue( "result", result );
	}

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.getResult();

		var exist = super.fire( "Attribute.codeExists", { code = rc.code, excludedId = rc.id } );

		result.setData( exist );

		event.setValue( "result", result );
	}

	function list( event, rc, prc ){
		var data   = [];
		var mm     = super.getMementify();
		var result = super.getResult();

		var params = super.paramsFromUrl();

		var rows = super.fire( "attribute.search", params );

		for ( var row in rows.getData() ) {
			var obj = mm.convert( row, "list" );
			data.add( obj );
		}

		result.setCount( rows.getCount() );
		result.setTotal( rows.getTotal() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function listRawValues( event, rc, prc ){
		var data   = [];
		var mm     = super.getMementify();
		var result = super.getResult();

		var params = super.paramsFromUrl();

		var rows = super.fire( "rawValue.search", params );

		for ( var row in rows.getData() ) {
			var obj = mm.convert( row, "list" );
			data.add( obj );
		}

		result.setCount( rows.getCount() );
		result.setTotal( rows.getTotal() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		var result = super.getResult();

		var row = super.fire( "attribute.get", [ rc.id ] );

		var obj = super.getMementify().convert( row, "list" );

		result.setTotal( 1 );
		result.setData( 1 );

		event.setValue( "result", obj );
	}

	function save( event, rc, prc ){
		var attr = super.bean( "Attribute" );

		var text   = super.bean( "Text" );
		var lang   = super.bean( "Lang" );
		var status = super.bean( "Status" );

		var thisId    = "";
		var messageId = "";
		var texts     = [];
		var values    = NullValue();

		var json = DeserializeJSON( GetHTTPRequestData().content );

		var categories = [];

		for ( var thisCategory in json.selectedCategories ) {
			var category = super.bean( "ProductCategory" );

			category.setId( thisCategory.id )
			categories.add( category );
		}

		var text = super.buildTextBean( json.nameItem, "NAME" );

		texts.add( text );

		attr.setId( json.id );
		attr.setCode( json.code );
		attr.setTexts( texts );
		attr.setStatus( status.setId( json.status.id ) );
		attr.setCategories( categories );

		if (
			!IsNull( json.values )
			AND !IsNull( json.values._data )
		) {
			values = [];

			for ( var value in json.values._data ) {
				var bean   = super.bean( "AttributeValue" );
				var status = super.bean( "Status" );

				bean.setAttributeId( json.id ); // TODO: better than this
				bean.setId( value.id );
				bean.setAllowNote( value.allowNote );
				bean.setAffectToImage( value.affectToImage );
				bean.setOrderBy( value.orderBy );

				bean.setStatus( status.setId( value.status.id ) );

				values.add( bean );
			}
		}

		attr.setValues( values );

		if ( !Len( json.id ) ) {
			messageId = "attribute.created";
			thisId    = super.fire( "attribute.create", [ attr ] )
		} else {
			messageId = "attribute.updated";
			thisId    = super.fire( "attribute.update", [ attr ] )
		}

		var message = completeMessage( messageId );

		event.setValue( "result", { "message" = message, "payload" = { "id" = thisId } } );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var list      = GetHTTPRequestData().content;
		var messageId = "attribute.deletedAllRecords";
		var payload   = "";

		// per ogni elemento: usato in preventivi in corso, bloccato; solo in
		// preventivi chiusi, eliminato logicamente; mai usato, cancellato
		var service = super.service( "Attribute" );
		var summary = super.service( "CatalogUsage" ).removeMany(
			"attributeIds",
			ListToArray( list ),
			function( id ){
				return service.delete( id );
			}
		);

		if ( summary.quotations.len() ) {
			result.setStatus( "INVALID" );
			result.setData( { "quotations" = summary.quotations } );
			event.setValue( "result", result );
			return;
		}

		if ( summary.errors.len() ) {
			messageId = "attribute.deletedNotAllRecords";
			payload   = { "errors" = summary.errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}
