component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="AttributeDAO";
	property name="textService" inject="TextService";
	property name="statusService" inject="StatusServive";
	property name="langService" inject="LangService";
	property name="attributeValueService" inject="AttributeValueService";
	property name="ProductCategoryService" inject="ProductCategoryService";
	property name="cacheScope" type="String" default="Attribute.bean";


	public com.apirone.core.model.bean.Attribute function get( required String attributeId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.attributeId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.attributeId );

		cm.put( getCacheScope(), arguments.attributeId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( attributeId = record.attribute_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.recordcount ) );

		return result;
	}


	public Boolean function idExists( required String attributeId ){
		var obj = get( attributeId = arguments.attributeId );

		if ( IsNull( obj ) ) {
			return false;
		}

		return true;
	}


	public String function create( required com.apirone.core.model.bean.Attribute attribute ){
		transaction {
			var newId = getDao().insert( arguments.attribute );

			for ( var text in attribute.getTexts() ) {
				var entity = super.bean( "Entity" );

				entity.setKey( "attribute.id" );
				entity.setValue( newId );

				text.setEntity( entity );
			}

			getTextService().bulkCreate( arguments.attribute.getTexts() );
		}

		return newId;
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.attribute_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	public String function update( required com.apirone.core.model.bean.Attribute attribute ){
		var id = arguments.attribute.getId();

		getDao().update( arguments.attribute );

		for ( var text in attribute.getTexts() ) {
			var entity = super.bean( "Entity" )

			entity.setKey( "attribute.id" );
			entity.setValue( id );

			text.setEntity( entity );

			if ( Len( text.getId() ) ) {
				getTextService().update( text );
			} else {
				getTextService().create( text );
			}
		}

		if ( !IsNull( attribute.getValues() ) ) {
			for ( var value in attribute.getValues() ) {
				if ( Len( value.getId() ) ) {
					// The bare minimum, only update value
					getAttributeValueService().update( value );
				}
			}
		}

		getCacheManager().remove( getCacheScope(), id );

		return id;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String attributeId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.attributeId );

		outcome.setData( { attributeId = arguments.attributeId } );

		transaction {
			try {
				var result = getDao().delete( arguments.attributeId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheScope(), arguments.attributeId );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteAttribute" );
				outcome.setMessage( "Cannot delete attribute [#arguments.attributeId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	private com.apirone.core.model.bean.Attribute function build( required String attributeId ){
		var record = getDao().read( arguments.attributeId );

		if ( record.recordCount ) {
			var bean = super.bean( "Attribute" );

			bean.setId( record.attribute_id );
			bean.setCreatedAt( record.created_at );
			bean.setcode( record.code );

			bean.setTexts( getTextService().list( attributeId = record.attribute_id ) )
			bean.setStatus( getStatusService().get( record.status_id ) );

			bean.setValues( getAttributeValueService().list( attributeId = record.attribute_id ) );

			var categories = super.getCategoriesBeanByIds( record.categories );

			bean.setCategories( categories );

			return bean;
		}

		return NullValue();
	}

}
