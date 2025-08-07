component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FontDAO";
	property name="fontService" inject="FontService";
	property name="textService" inject="TextService";

	property name="cacheScope" type="String" default="Font.bean";

	public com.apirone.core.model.bean.Font function get( required String fontId ){
		var cm = super.getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.fontId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( arguments.fontId );
		cm.put( getCacheScope(), arguments.fontId, bean );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit    = 15,
		required Numeric offset   = 0,
		required Array orderBy    = [ { field = "font.id" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments.orderby, "font" );

		var records = getDao().find( argumentCollection = arguments );

		records.each( function( record ){
			rows.add( get( fontId = record.font_id ) );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.font_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	public String function create( required com.apirone.core.model.bean.Font font ){
		var newId = getDao().insert( arguments.font );

		if ( Len( arguments.font.getTexts() ) ) {
			transaction {
				for ( var text in arguments.font.getTexts() ) {
					var entity = super.bean( "Entity" );

					entity.setKey( "font.id" );
					entity.setValue( newId );

					text.setEntity( entity );
				}

				getTextService().bulkCreate( arguments.font.getTexts() );
			}
		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.Font font ){
		getDao().update( arguments.font );

		var id = arguments.font.getId();

		if ( Len( arguments.font.getTexts() ) ) {
			transaction {
				for ( var text in arguments.font.getTexts() ) {
					var entity = super.bean( "Entity" )

					entity.setKey( "font.id" );
					entity.setValue( id );

					text.setEntity( entity );

					if ( Len( text.getId() ) ) {
						getTextService().update( text );
					} else {
						getTextService().create( text );
					}
				}
			}
		}

		super.getCacheManager().remove( getCacheScope(), arguments.font.getId() );

		return arguments.font.getId();
	}


	public com.apirone.core.model.bean.Outcome function delete( required String fontId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.fontId );

		outcome.setData( { fontId = arguments.fontId } );

		transaction {
			try {
				var result = getDao().delete( arguments.fontId );
				outcome.setData( { "deletedCount" = result } )

				super.getCacheManager().remove( getCacheScope(), arguments.fontId );
			} catch ( any error ) {

				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteFont" );
				outcome.setMessage( "Cannot delete font [#arguments.fontId#]" );
			}
		}

		return outcome;
	}



	/*
    	private method
	*/

	private com.apirone.core.model.bean.Font function build( required String fontId ){
		var record = getDao().read( arguments.fontId );

		if ( record.recordCount ) {
			var bean = super.bean( "Font" );

			bean.setId( record.font_id );
			bean.setCode( record.code );
			bean.setDirectory( record.directory );
			bean.setDimension( record.dimension );

			bean.setTexts( getTextService().list( fontId = record.font_id ) );
			bean.setCreatedAt( record.created_at );

			return bean;
		}

		return NullValue();
	}

}
