component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FontFamilyDAO";
	property name="textService" inject="TextService";
	property name="pictogramService" inject="PictogramService";
	property name="fontFamilySizeService" inject="FontFamilySizeService";

	public com.apirone.core.model.bean.FontFamily function get( required String fontFamilyId ){
		return build( arguments.fontFamilyId );
	}

	public com.apirone.core.model.bean.FontFamily function getFontFamilyBySignageConfigId( required Numeric signageConfigId ){
		var record = getDao().getFontFamilyBySignageConfigId( arguments.signageConfigId );

		var bean = build( record.fontFamilyId );

		return bean;
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "fontFamily.code" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments.orderby );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids     = [];
		records.each( function( r ){
			ids.append( r.font_family_id ); // PK intero
		} );

		var beanMap = {};

		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );
			allRecords.each( function( r ){
				beanMap[ r.font_family_id ] = buildFromRow( r );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( r ){
			rows.add( beanMap[ r.font_family_id ] );
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
			&& record.font_family_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	public String function create( required com.apirone.core.model.bean.FontFamily fontFamily ){
		var newId = getDao().insert( arguments.fontFamily );
		return newId;
	}

	public String function update( required com.apirone.core.model.bean.FontFamily fontFamily ){
		getDao().update( arguments.fontFamily );

		return arguments.fontFamily.getId();
	}

	public com.apirone.core.model.bean.Outcome function delete( required String fontFamilyId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.fontFamilyId );

		outcome.setData( { fontFamilyId = arguments.fontFamilyId } );

		var result = getDao().delete( arguments.fontFamilyId );
		outcome.setData( { "deletedCount" = result } )

		super.logEvent(
			event   = "FONT_FAMILY.deleted",
			message = "Font [#arguments.fontFamilyId#] deleted",
			payload = { "id" = arguments.fontFamilyId }
		);

		return outcome;
	}


	/*
    	private method
	*/

	/**
	 * Costruisce un bean FontFamily a partire dall'ID, effettuando la lettura dal DB.
	 */
	private com.apirone.core.model.bean.FontFamily function build( required String fontFamilyId ){
		var record = getDao().read( arguments.fontFamilyId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean FontFamily a partire da una riga della query.
	 * Utilizzato sia da build() (record singolo) che da search() (iterazione batch).
	 * Le sub-entity (pictograms, sizes) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.FontFamily function buildFromRow( required any record ){
		var bean = super.bean( "FontFamily" );

		// Campi diretti dal record
		bean.setId( record.font_family_id );
		bean.setCode( record.code );
		bean.setName( record.font_family );

		// Entity collegate (caricate singolarmente)
		var pictograms = getPictogramService().list( fontFamilyId = record.font_family_id );

		if ( Len( pictograms ) ) {
			bean.setPictograms( pictograms );
		}

		var sizes = getFontFamilySizeService().list( fontFamilyId = record.font_family_id );

		bean.setSizes( sizes );

		return bean;
	}

}
