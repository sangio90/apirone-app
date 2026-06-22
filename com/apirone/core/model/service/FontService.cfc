component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FontDAO";
	property name="fontService" inject="FontService";
	property name="fontFamilyService" inject="FontFamilyService";
	property name="textService" inject="TextService";

	public com.apirone.core.model.bean.Font function get( required String fontId ){
		return build( arguments.fontId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;
		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String str,
		required Numeric limit  = 15,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "font.id" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments.orderby, "font" );

		// Il find() restituisce gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.font_id );
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.font_id ] );
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

	/**
	 * @auditEvent font.created
	 * @auditMessage Font [@return@] created
	 * @auditPayload { "id": "@return@" }
	 */
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

	/**
	 * @auditEvent font.updated
	 * @auditMessage Font [@font.id@] updated
	 * @auditPayload { "id": "@font.id@" }
	 */
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

				super.logEvent(
					event   = "font.deleted",
					message = "Font [#arguments.fontId#] deleted",
					payload = { "id" = arguments.fontId }
				);
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

	/**
	 * Recupera in batch più Font dato un array di ID.
	 * Restituisce uno Struct chiave = fontId, valore = bean Font.
	 * Precarica FontFamily e testi in batch per evitare il problema N+1.
	 *
	 * @ids Array di fontId
	 * @return Struct mappato per fontId -> Font
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie tutti i font_family_id per precaricarli in batch
		var familyIds = [];
		for ( var record in records ) {
			if ( !IsNull( record.font_family_id ) ) {
				familyIds.append( record.font_family_id );
			}
		}

		// Precarica le FontFamily in batch (via readByIds del DAO, senza getMany pubblico)
		var familyMap = {};
		if ( ArrayLen( familyIds ) ) {
			var familyRecords = getFontFamilyService().getDao().readByIds( familyIds );
			for ( var fr in familyRecords ) {
				var familyBean = super.bean( "FontFamily" );
				familyBean.setId( fr.font_family_id );
				familyBean.setCode( fr.code );
				familyBean.setName( fr.font_family );
				familyMap[ fr.font_family_id ] = familyBean;
			}
		}

		// Precarica i testi in batch per tutti i font (1 query invece di N)
		var textMap = getTextService().listByEntityIds( "font.id", arguments.ids );

		// Costruisce i bean con le mappe pre-caricate
		for ( var record in records ) {
			var bean = super.bean( "Font" );

			// Campi diretti dal record
			bean.setId( record.font_id );
			bean.setCode( record.code );
			bean.setDirectory( record.directory );
			bean.setHeightWidthRatio( record.height_width_ratio );

			// FontFamily: dalla mappa pre-caricata
			if ( !IsNull( record.font_family_id ) && StructKeyExists( familyMap, record.font_family_id ) ) {
				bean.setFontFamily( familyMap[ record.font_family_id ] );
			} else {
				bean.setFontFamily( super.bean( "FontFamily" ) );
			}

			// Testi: dalla mappa pre-caricata
			if ( StructKeyExists( textMap, record.font_id ) ) {
				bean.setTexts( textMap[ record.font_id ] );
			}

			bean.setCreatedAt( record.created_at );

			map[ record.font_id ] = bean;
		}

		return map;
	}

	/**
	 * Costruisce un bean Font a partire dall'ID. Delega a buildFromFindRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.Font function build( required String fontId ){
		var record = getDao().read( arguments.fontId );

		if ( record.recordCount ) {
			return buildFromFindRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Font a partire da una riga della query.
	 * Le sub-entity (FontFamily, Text) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.Font function buildFromFindRow( required any record ){
		var bean = super.bean( "Font" );

		// Campi diretti dal record
		bean.setId( record.font_id );
		bean.setCode( record.code );
		bean.setDirectory( record.directory );
		bean.setHeightWidthRatio( record.height_width_ratio );

		// Entity collegate (caricate singolarmente)
		bean.setFontFamily(
			!IsNull( record.font_family_id ) ? getFontFamilyService().get( record.font_family_id ) : super.bean( "FontFamily" )
		)

		bean.setTexts( getTextService().list( fontId = record.font_id ) );
		bean.setCreatedAt( record.created_at );

		return bean;
	}

}
