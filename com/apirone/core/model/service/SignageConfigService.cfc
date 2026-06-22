component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="SignageConfigDAO";
	property name="fontService" inject="fontService";
	property name="catalogBundleService" inject="catalogBundleService";
	property name="signageConfigItemService" inject="signageConfigItemService";
	property name="FontFamilySizeService" inject="FontFamilySizeService";
	property name="textService" inject="TextService";

	public com.apirone.core.model.bean.SignageConfig function get( required String signageConfigId ){
		return build( arguments.signageConfigId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}

	public com.apirone.core.model.bean.Result function search(
		String catalogBundleId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "signageConfig.id", desc = "desc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.signage_config_id );
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.signage_config_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public Numeric function create( required com.apirone.core.model.bean.SignageConfig signageConfig ){
		if ( !Len( signageConfig.getCatalogBundle().getId() ) ) {
			var catalogBundle = getCatalogBundleService().getOrCreate( signageConfig.getCatalogBundle() );

			signageConfig.getCatalogBundle().setId( catalogBundle.getId() );
		}

		var newId = getDao().insert( arguments.signageConfig );

		for ( var item in arguments.signageConfig.getItems() ) {
			item.setSignageConfigId( newId );

			if ( Len( item.getId() ) ) {
				getSignageConfigItemService().update( item );
			} else {
				getSignageConfigItemService().create( item );
			}
		}

		return newId;
	}

	public Numeric function update( required com.apirone.core.model.bean.SignageConfig signageConfig ){
		// var newId = getDao().update( arguments.signageConfig );

		for ( var item in arguments.signageConfig.getItems() ) {
			item.setSignageConfigId( signageConfig.getId() );

			if ( Len( item.getId() ) ) {
				getSignageConfigItemService().update( item );
			} else {
				getSignageConfigItemService().create( item );
			}
		}

		return signageConfig.getId();
	}

	public com.apirone.core.model.bean.Outcome function delete( required String signageConfigId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.signageConfigId );

		outcome.setData( { signageConfigId = arguments.signageConfigId } );

		transaction {
			try {
				var result = getDao().delete( arguments.signageConfigId );
				outcome.setData( { "deletedCount" = result } )
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteSignageConfig" );
				outcome.setMessage( "Cannot delete signageConfig [#arguments.signageConfigId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	/**
	 * Recupera in batch più SignageConfig dato un array di ID.
	 * Restituisce uno Struct chiave = signageConfigId, valore = bean SignageConfig.
	 * Precarica font, catalogBundle e configItems in batch per evitare il problema N+1.
	 *
	 * @ids Array di signageConfigId
	 * @return Struct mappato per signageConfigId -> SignageConfig
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie gli ID unici di font e catalogBundle da tutti i record
		var fontIds          = [];
		var catalogBundleIds = [];
		for ( var record in records ) {
			if ( !IsNull( record.font_id ) ) {
				fontIds.append( record.font_id );
			}
			if ( !IsNull( record.catalog_bundle_id ) ) {
				catalogBundleIds.append( record.catalog_bundle_id );
			}
		}

		// Precarica i font in batch: FontService non ha getMany(), usa FontDAO.readByIds
		var fontMap = {};
		if ( ArrayLen( fontIds ) ) {
			var uniqueFontIds = [];
			for ( var fid in fontIds ) {
				if ( !IsNull( fid ) && !ArrayContains( uniqueFontIds, fid ) ) {
					uniqueFontIds.append( fid );
				}
			}
			if ( ArrayLen( uniqueFontIds ) ) {
				var fontRecords = getFontService().getDao().readByIds( uniqueFontIds );

				// Precarica i testi per i Font in batch
				var fontTextMap = getTextService().listByEntityIds( "font.id", uniqueFontIds );

				for ( var fr in fontRecords ) {
					var fontBean = super.bean( "Font" );
					fontBean.setId( fr.font_id );
					fontBean.setCode( fr.code );
					fontBean.setDirectory( fr.directory );
					fontBean.setHeightWidthRatio( fr.height_width_ratio );
					fontBean.setCreatedAt( fr.created_at );
					// Testi: dalla mappa pre-caricata
					if ( StructKeyExists( fontTextMap, fr.font_id ) ) {
						fontBean.setTexts( fontTextMap[ fr.font_id ] );
					}
					fontMap[ fr.font_id ] = fontBean;
				}
			}
		}

		// Precarica i catalogBundle in batch: CatalogBundleService non ha getMany(), usa DAO
		var bundleMap = {};
		if ( ArrayLen( catalogBundleIds ) ) {
			var uniqueBundleIds = [];
			for ( var bid in catalogBundleIds ) {
				if ( !IsNull( bid ) && !ArrayContains( uniqueBundleIds, bid ) ) {
					uniqueBundleIds.append( bid );
				}
			}
			if ( ArrayLen( uniqueBundleIds ) ) {
				var bundleRecords = getCatalogBundleService().getDao().readByIds( uniqueBundleIds );
				for ( var br in bundleRecords ) {
					var bundleBean = super.bean( "CatalogBundle" );
					bundleBean.setId( br.catalog_bundle_id );
					bundleBean.setName( br.catalog_bundle );
					bundleBean.setCreatedAt( br.created_at );
					bundleBean.setMarkupValue( br.markup_value );
					// Line, Model, Category: non precaricati in batch (sono leggeri)
					bundleMap[ br.catalog_bundle_id ] = bundleBean;
				}
			}
		}

		// Precarica i SignageConfigItem in batch per tutti i config ID (1 sola query)
		var itemMap = {};
		var fontSizes = {};
		if ( ArrayLen( arguments.ids ) ) {
			var itemRecords = getSignageConfigItemService().getDao().readBySignageConfigIds( arguments.ids );
			for ( var ir in itemRecords ) {
				if ( !StructKeyExists( itemMap, ir.signage_config_id ) ) {
					itemMap[ ir.signage_config_id ] = [];
				}
			var scItem = super.bean( "SignageConfigItem" );
			scItem.setId( ir.signage_config_item_id );
			scItem.setSignageConfigId( ir.signage_config_id );
			scItem.setCreatedAt( ir.created_at );
			scItem.setHeight( ir.height );
			scItem.setHeightInPixel( ir.height_in_pixel );
			scItem.setRowCount( ir.row_count );
			scItem.setCharCount( ir.char_count );
			scItem.setLineHeights( IsNull( ir.line_heights ) ? [] : DeserializeJSON( ir.line_heights.toString() ) );
			if ( !IsNull( ir.font_family_size_id ) ) {
				if ( !StructKeyExists( fontSizes, ir.font_family_size_id ) ) {
					fontSizes[ ir.font_family_size_id ] = getFontFamilySizeService().get( ir.font_family_size_id );
				}
				scItem.setSize( fontSizes[ ir.font_family_size_id ] );
			}
				itemMap[ ir.signage_config_id ].append( scItem );
			}
		}

		for ( var record in records ) {
			var bean = super.bean( "SignageConfig" );

			// Campi diretti dal record
			bean.setId( record.signage_config_id );
			bean.setCreatedAt( record.created_at );

			// Font: dalla mappa pre-caricata
			if ( !IsNull( record.font_id ) && StructKeyExists( fontMap, record.font_id ) ) {
				bean.setFont( fontMap[ record.font_id ] );
			} else if ( !IsNull( record.font_id ) ) {
				bean.setFont( getFontService().get( record.font_id ) );
			}

			// CatalogBundle: dalla mappa pre-caricata
			if ( !IsNull( record.catalog_bundle_id ) && StructKeyExists( bundleMap, record.catalog_bundle_id ) ) {
				bean.setCatalogBundle( bundleMap[ record.catalog_bundle_id ] );
			} else if ( !IsNull( record.catalog_bundle_id ) ) {
				bean.setCatalogBundle( getCatalogBundleService().get( record.catalog_bundle_id ) );
			}

			// Items: dalla mappa pre-caricata
			if ( StructKeyExists( itemMap, record.signage_config_id ) ) {
				bean.setItems( itemMap[ record.signage_config_id ] );
			}

			map[ record.signage_config_id ] = bean;
		}

		return map;
	}

	/**
	 * Costruisce un bean SignageConfig a partire dall'ID. Delega a buildFromRow() dopo la lettura del record.
	 */
	private com.apirone.core.model.bean.SignageConfig function build( required String signageConfigId ){
		var record = getDao().read( arguments.signageConfigId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean SignageConfig a partire da una riga del query.
	 * Le sub-entity (Font, CatalogBundle, SignageConfigItems) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.SignageConfig function buildFromRow( required any record ){
		var bean = super.bean( "SignageConfig" );

		// Campi diretti dal record
		bean.setId( arguments.record.signage_config_id );
		bean.setCreatedAt( arguments.record.created_at );

		// Entity collegate (caricate singolarmente)
		bean.setFont( getFontService().get( arguments.record.font_id ) );
		bean.setCatalogBundle( getCatalogBundleService().get( arguments.record.catalog_bundle_id ) );
		bean.setItems( getSignageConfigItemService().list( arguments.record.signage_config_id ) );

		return bean;
	}

}
