component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var dm     = getDataMapper();

		var params = super.paramsFromUrl();

		var rows = super.fire( "line.search", params );

		for ( var row in rows.getData() ) {
			var obj = dm.convert( row, "Line", true );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	// TODO: potrei usare solo list
	function listByCategoryId( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var dm     = getDataMapper();

		var params = super.paramsFromUrl();

		var params[ "categoryId" ] = rc.categoryId;

		var rows = super.fire( "line.search", params );

		for ( var row in rows.getData() ) {
			var obj = dm.convert( row, "Line", true );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function clone( event, rc, prc ){
		var params = {
			fromLineId = rc.fromLineId,
			toLineId   = rc.toLineId,
			categoryId = rc.categoryId
		}

		var result = super.fire( "line.clone", params );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		param rc.id = "___";
		var result  = super.getResult();

		if ( !super.isUuid( rc.id ) ) {
			return event.setValue( "result", "No UUID" );
		}

		var bean = super.fire( "line.get", [ rc.id ] );

		var obj = super.getDataMapper().convert( bean, "Line", true );

		if ( !obj.keyExists( "thickness" ) ) {
			obj[ "thickness" ] = { "id" = "", "name" = "" }
		}

		result.setData( obj );

		event.setValue( "result", result );
	}

	function attributes( event, rc, prc ){
		param rc.str = "";
		var result   = super.getResult();

		var params = {}

		params.str = Len( rc.str ) ? rc.str : NullValue();

		var list = fire( "attributes.search", params );

		result = list;

		event.setValue( "result", result );
	}

	function createProduct( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var line     = super.bean( "Line" );
		var size     = super.bean( "Size" );
		var finish   = super.bean( "Finish" );
		var product  = super.bean( "Product" );
		var status   = super.bean( "Status" );
		var category = super.bean( "ProductCategory" );

		product.setLine( line.setId( rc.id ) );
		product.setFinish( finish.setId( json.finishId ) );
		product.setSize( size.setId( json.sizeId ) );
		// product.setCategory( category.setId( 22 ) ); // TODO: check if this value is ok here
		product.setCategory( category.setId( json.categoryId ) );
		product.setStatus( status.setId( "ACT" ) );

		var newId = super.fire( "product.create", [ product ] );

		var message = super.completeMessage( "product.created" );

		var obj = super.fire( "product.get", [ newId ] );

		event.setValue(
			"result",
			{
				"message" = message,
				"payload" = {
					"productId" = newId,
					"finishId"  = obj.getFinish().getId(),
					"sizeId"    = obj.getSize().getId()
				}
			}
		);
	}

	function deleteProduct( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		super.fire(
			"product.deleteByParams",
			{
				sizeId   = json.sizeId,
				lineId   = rc.id,
				finishId = json.finishId
			}
		);

		var message = super.completeMessage( "product.deleted" );

		event.setValue( "result", { "message" = message } );
	}

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "line.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var thisId     = "";
		var messageId  = "";
		var categories = [];

		var result    = super.getResult();
		var line      = super.bean( "Line" );
		var status    = super.bean( "Status" );
		var thickness = super.bean( "Thickness" );
		var category  = super.bean( "ProductCategory" );
		var text      = super.bean( "Text" );
		var lang      = super.bean( "Lang" );

		for ( var thisCategory in json.selectedCategories ) {
			var category = super.bean( "ProductCategory" );

			category.setId( thisCategory.id )
			categories.add( category );
		}

		line.setId( json.id );
		line.setCode( json.code );
		line.setName( json.name );

		line.setStatus( status.setId( json.status.id ) );
		line.setCategories( categories );
		line.setThickness( thickness.setId( json?.thickness?.id ) );

		text.setLang( lang.setId( json.mainText.lang.id ) );

		text.setId( json.mainText.id );
		text.setName( json.mainText.name );

		line.setTexts( [ text ] );

		if ( !Len( json.id ) ) {
			messageId = "line.created";
			thisId    = super.fire( "line.create", [ line ] )
		} else {
			messageId = "line.updated";
			thisId    = super.fire( "line.update", [ line ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}


	function delete( event, rc, prc ){
		var result    = super.getResult();
		var list      = GetHTTPRequestData().content;
		var messageId = "line.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( list );

		for ( var id in ids ) {
			var outcome = super.fire( "line.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "line.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}
