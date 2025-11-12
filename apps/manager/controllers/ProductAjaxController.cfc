component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var mm     = super.getMementify();
		var params = super.paramsFromUrl();

		params[ "categoryModeId" ] = "COM";

		var rows = super.fire( "product.search", params );

		for ( var row in rows.getData() ) {
			var obj = mm.convert( row, "list" );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		param rc.id = "___";
		var result  = super.getResult();

		if ( !super.isUuid( rc.id ) ) {
			return event.setValue( "result", "No UUID" );
		}

		var bean = super.fire( "Product.get", [ rc.id ] );

		var obj = super.getDataMapper().convert( bean, "Product", true );

		result.setData( obj );

		event.setValue( "result", result );
	}

	// used by app-signage-config-item too, with missingValues=false
	function listItems( event, rc, prc ){
		param rc.missingValues = true;

		var result = getFlatTree( productId = rc.id, includeMissingValues = rc.missingValues );

		event.setValue( "result", result );
	}

	function listItemsForSort( event, rc, prc ){
		var result = getFlatTree( productId = rc.id, includeMissingValues = false );

		event.setValue( "result", result );
	}

	function listAttributesForSort( event, rc, prc ){
		private Boolean function exists( required attributeId, required attrs ){
			for ( var attr in arguments.attrs ) {
				if ( attr.id == arguments.attributeId ) {
					return true;
				}
			}

			return false;
		}

		var attrs = [];

		var rows = getFlatTree( productId = rc.id, includeMissingValues = false );

		for ( var row in rows.getData() ) {
			if ( !exists( row.attribute.id, attrs ) ) {
				var item = row.attribute;

				item[ "level" ]   = row.level;
				item[ "spaces" ]  = RepeatString( "&nbsp;&nbsp;&nbsp;&nbsp;", row.level );
				item[ "shortId" ] = Right( item.id, 5 );

				attrs.add( item );
			}
		}

		event.setValue( "result", attrs );
	}

	function addItem( event, rc, prc ){
		var result = super.getResult();

		param rc.id          = "_"; // Current product
		param rc.originId    = 0; // Parent item, if exists
		param rc.attributeId = 0; // To add values ​​to this attribute

		linkAttribute(
			productId   = rc.id,
			originId    = rc.originId,
			attributeId = rc.attributeId
		);

		var message = completeMessage( "product.itemsAdded" );

		result.setData( { "message" = message } );

		event.setValue( "result", result );
	}

	function removeItems( event, rc, prc ){
		var result = super.getResult();

		param rc.items = "_";

		```
		<!--- TODO: better than this --->
		<cfquery datasource="apirone">
			DELETE FROM product_items
			WHERE product_item_id IN ( #rc.items# )
		</cfquery>
		```

		var message = completeMessage( "product.itemsDeleted" );

		result.setData( { "message" = message } );

		event.setValue( "result", result );
	}

	function addValue( event, rc, prc ){
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var data   = [];
		var result = super.getResult();

		var item   = super.bean( "ProductItem" );
		var origin = super.bean( "ProductItem" );
		var value  = super.bean( "AttributeValue" );
		var status = super.bean( "Status" );

		status.setId( "ACT" ); // Active
		value.setId( json.attributeValue.id );

		// item.setOrderBy( json.orderBy );
		item.setOrderBy( 10 );

		item.setProductId( rc.id );
		item.setAttributeValue( value );
		item.setStatus( status );
		item.setOrigin( origin.setId( json?.origin?.id ) ?: NullValue() );

		var newId = super.fire( "ProductItem.create", { productItem = item } );

		var message = completeMessage( "product.valueAdded" );

		result.setData( { "message" = message, "payload" = { "id" = newId } } );

		event.setValue( "result", result );
	}

	function sortItems( event, rc, prc ){
		var result = super.getResult();

		var list  = ReplaceList( GetHTTPRequestData().content, "[,]", "" ); // string: [1,2,3] with brackets.
		var items = ListToArray( list );

		var json = DeserializeJSON( GetHTTPRequestData().content );

		var orderby = 10;

		for ( var item in items ) {
			var bean = super.fire( "ProductItem.get", { productItemId = item } );
			bean.setOrderBy( orderby );

			super.fire( "ProductItem.update", { productItem = bean } );

			orderby += 10;
		}

		var message = completeMessage( "product.valuesReordered" );

		result.setData( { "message" = message } );

		event.setValue( "result", result );
	}

	function sortAttributes( event, rc, prc ){
		var result = super.getResult();

		var list  = ReplaceList( GetHTTPRequestData().content, "[,],""", "" ); // string: [1,2,3] with brackets.
		var attrs = ListToArray( list );

		var orderby = 10;

		for ( var attr in attrs ) {
			var items = super.fire( "ProductItem.list", { productId = rc.id, attributeId = attr } );

			for ( var item in items ) {
				var bean = super.fire( "ProductItem.get", { productItemId = item.getId() } );
				bean.setOrderBy( orderby );

				super.fire( "ProductItem.update", { productItem = bean } );

				orderby += 10;
			}
		}

		var message = completeMessage( "product.valuesReordered" );

		result.setData( { "message" = message } );

		event.setValue( "result", result );
	}

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "product.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function getIdAndFileByParams( event, rc, prc ){
		var result         = super.getResult();
		var data           = {}
		var catalogBundles = super.fire(
			"catalogBundle.list",
			{
				categoryId = rc.categoryId,
				lineId     = rc.lineId,
				modelId    = rc.modelId
			}
		)
		if ( Len( catalogBundles ) ) {
			var catalogBundle = catalogBundles[ 1 ];
			var products      = super.fire(
				"product.list",
				{
					catalogBundleId = catalogBundle.getId(),
					finishId        = rc.finishId
				}
			);
			if ( Len( products ) ) {
				var productId    = products[ 1 ].getId()
				var files        = super.fire( "file.list", { productId = productId } )
				result.productId = productId;
				data.set( "productId", productId )
				if ( Len( files ) ) {
					var file = files[ 1 ];
					json     = super.getMementify().convert( file, "list" );
					data.set( "file", json )
				}
				result.setData( data )
			}
		}

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var result = super.getResult();

		var product    = super.bean( "Product" );
		var status     = super.bean( "Status" );
		var statusText = super.bean( "Status" );
		var text       = super.bean( "Text" );
		var lang       = super.bean( "Lang" );
		var category   = super.bean( "ProductCategory" );

		var json = DeserializeJSON( GetHTTPRequestData().content );

		product.setId( json.id );
		product.setCode( json.code );

		product.setStatus( status.setId( json.status.id ) );
		product.setPositionCount( json.positionCount )

		text.setLang( lang.setId( "IT" ) );
		text.setStatus( statusText.setId( "ACT" ) );

		text.setId( json?.nameItem?.id );
		text.setName( json.nameItem.name );

		product.setTexts( [ text ] );
		product.setCategory( category.setId( json.category.id ) );

		if ( !Len( json.id ) ) {
			var messageId = "product.created";
			var thisId    = super.fire( "product.create", [ product ] )
		} else {
			var messageId = "product.updated";
			var thisId    = super.fire( "product.update", [ product ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function saveDetail( event, rc, prc ){
		var result = super.getResult();

		var product    = super.bean( "Product" );
		var status     = super.bean( "Status" );

		var json = DeserializeJSON( GetHTTPRequestData().content );


		product.setId( json.id );
		product.setStatus( status.setId( json.status.id ) );
		product.setMinQuantity( json?.minQuantity ?: 0 );
		product.setMaxQuantity( json?.maxQuantity ?: 0 );
		
		if ( StructKeyExists( json, "special" ) ) {
			product.setSpecial( json.special );
		} else {
			product.setSpecial( false );
		}

		var thisId = super.fire( "product.updateDetail", [ product ] )

		var message = completeMessage( "product.updated" );

		result.setData( { "message" = message }, { "payload" = { id = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var list      = GetHTTPRequestData().content;
		var messageId = "product.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( list );

		for ( var id in ids ) {
			var outcome = super.fire( "product.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "product.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}


	/*
		combinations
	*/

	function combinations( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var memy   = super.getMementify();

		var rows = super.service( "Combination" ).getByProductId( rc.id );

		for ( var row in rows.getData() ) {
			var obj = memy.convert( row );
			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function calculateCombinations( event, rc, prc ){
		var result = super.getResult();
		super.service( "Combination" ).calculateCombinations( rc.id );
		event.setValue( "result", result );
	}

	function deleteCombinations( event, rc, prc ){
		var result    = super.getResult();
		var list      = GetHTTPRequestData().content;
		var messageId = "combination.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( list );

		for ( var id in ids ) {
			var outcome = super.fire( "combination.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "product.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}


	/*
        private methods
    */

	private Boolean function linkAttribute(
		required String productId,
		required String attributeId,
		Numeric originId = 0
	){
		// TODO: better than this

		var attribute = super.fire( "attribute.get", [ arguments.attributeId ] );

		```
		<cftransaction>
			<cfquery datasource="apirone" name="orderBy">
				SELECT MAX( orderby ) AS max_orderby
				FROM
					product_items
				WHERE product_id = <cfqueryparam cfsqltype="Varchar" value="#arguments.productId#">::uuid
			</cfquery>

			<cfif orderBy.recordCount>
				<cfset startOrderBy = orderBy.max_orderby>
			<cfelse>
				<cfset startOrderBy = 10>
			</cfif>

			<!--- TODO: use ProductItem.create --->
			<cfloop array="#attribute.getValues()#" item="item">
				<cfquery datasource="apirone">
					INSERT INTO product_items (
						product_id,
						attribute_raw_value_id,
						orderby,
						origin_id,
						status_id
					)
					VALUES (
						'#productId#',
						'#item.getId()#',
						#startOrderBy + item.getOrderBy()#,
						#( Val( arguments.originId ) ? arguments.originId : "NULL" )#,
						'ACT'
					)
				</cfquery>
			</cfloop>
		</cftransaction>
		```
		return true;
	}

	private function getFlatTree( productId, includeMissingValues = true ){
		var data   = [];
		var result = super.getResult();

		var params = {
			productId            = arguments.productId,
			includeMissingValues = arguments.includeMissingValues
		};

		var items = super.fire( "ProductItem.getFlatTree", params );

		var data = super.eachParallelAndReorder(
			items,
			function(item, index) {
				var row = super.getMementify().convert( item, "tree" ); // TODO: use "treelight" instead?
				row[ "spaces" ] = RepeatString( "&nbsp;&nbsp;&nbsp;&nbsp;", item.getLevel() );
				//item.processed = true;
				return row;
			}
		);

		result.setTotal( data.len() );
		result.setCount( data.len() );
		result.setData( data );

		return result;
	}

}
