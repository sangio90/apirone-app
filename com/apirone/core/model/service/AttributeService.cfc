component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="AttributeDAO";
	property name="textService" inject="TextService";
	property name="statusService" inject="statusService";
	property name="langService" inject="LangService";
	property name="attributeValueService" inject="AttributeValueService";
	property name="ProductCategoryService" inject="ProductCategoryService";


	public com.apirone.core.model.bean.Attribute function get( required String attributeId ){
		return build( arguments.attributeId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(){
		var rows   = [];
		var result = super.getResult();

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		records.each( function( r ){
			ids.append( r.attribute_id );
		} );

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( record ){
			rows.add( beanMap[ record.attribute_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

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

		return id;
	}

	/**
	 * Recupera in batch più Attribute dato un array di ID.
	 * Restituisce uno Struct chiave = attributeId, valore = bean Attribute.
	 * Precarica i testi e le categorie in batch per evitare il problema N+1.
	 *
	 * @ids Array di attributeId
	 * @return Struct mappato per attributeId -> Attribute
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Precarica i testi in batch per tutti gli attributi (1 query invece di N)
		var textMap = getTextService().listByEntityIds( "attribute.id", arguments.ids );

		// Precarica le categorie in batch: raccoglie tutti i category_id
		// dai JSONB categories di ogni attributo e li carica con getMany() ottimizzato
		var allCatIds = [];
		for ( var record in records ) {
			var cats = IsNull( record.categories ) ? [] : DeserializeJSON( record.categories );
			if ( !IsNull( cats ) && ArrayLen( cats ) ) {
				for ( var cid in cats ) {
					allCatIds.append( cid );
				}
			}
		}
		var catMap = {};
		if ( ArrayLen( allCatIds ) ) {
			catMap = getProductCategoryService().getMany( allCatIds );
		}

		// Precarica tutti gli AttributeValue in batch tramite DAO
		var valueMap = {};
		if ( ArrayLen( arguments.ids ) ) {
			var valueRecords = getAttributeValueService().getDao().readByAttributeIds( arguments.ids );
			for ( var vr in valueRecords ) {
				if ( !StructKeyExists( valueMap, vr.attribute_id ) ) {
					valueMap[ vr.attribute_id ] = [];
				}
				var vBean = super.bean( "AttributeValue" );
				vBean.setId( vr.attribute_raw_value_id );
				vBean.setAttributeId( vr.attribute_id.toString() );
				vBean.setCreatedAt( vr.created_at );
				vBean.setOrderBy( vr.orderby );
				vBean.setAllowNote( vr.allow_note ? true : false );
				vBean.setAffectToImage( vr.affect_to_image ? true : false );
				vBean.setComponentCount( vr.component_count );
				vBean.setStatus( getStatusService().get( vr.status_id ) );
				// rawValue e images: non caricati in batch (richiesti solo in contesti specifici)
				valueMap[ vr.attribute_id ].append( vBean );
			}
		}

		// Cache locali per status
		var statuses = {};

		for ( var record in records ) {
			var bean = super.bean( "Attribute" );

			// Campi diretti dal record
			bean.setId( record.attribute_id );
			bean.setCreatedAt( record.created_at );
			bean.setCode( record.code );

			// Status: cached localmente
			if ( !StructKeyExists( statuses, record.status_id ) ) {
				statuses[ record.status_id ] = getStatusService().get( record.status_id );
			}
			bean.setStatus( statuses[ record.status_id ] );

			// Testi: dalla mappa pre-caricata
			if ( StructKeyExists( textMap, record.attribute_id ) ) {
				bean.setTexts( textMap[ record.attribute_id ] );
			}

			// Valori: dalla mappa pre-caricata
			if ( StructKeyExists( valueMap, record.attribute_id ) ) {
				bean.setValues( valueMap[ record.attribute_id ] );
			}

			// Categorie: dalla mappa pre-caricata
			var cats = IsNull( record.categories ) ? [] : DeserializeJSON( record.categories );
			var catBeans = [];
			if ( !IsNull( cats ) && ArrayLen( cats ) ) {
				for ( var cid in cats ) {
					if ( StructKeyExists( catMap, cid ) ) {
						catBeans.append( catMap[ cid ] );
					}
				}
			}
			bean.setCategories( ArrayLen( catBeans ) ? catBeans : [] );

			map[ record.attribute_id ] = bean;
		}

		return map;
	}

	public com.apirone.core.model.bean.Outcome function delete( required String attributeId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.attributeId );

		outcome.setData( { attributeId = arguments.attributeId } );

		transaction {
			try {
				var result = getDao().delete( arguments.attributeId );
				outcome.setData( { "deletedCount" = result } )
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
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Attribute a partire da una riga della query.
	 * Le sub-entity (Texts, Status, Values, Categories) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.Attribute function buildFromRow( required any record ){
		var bean = super.bean( "Attribute" );

		// Campi diretti dal record
		bean.setId( arguments.record.attribute_id );
		bean.setCreatedAt( arguments.record.created_at );
		bean.setCode( arguments.record.code );

		// Entity collegate (caricate singolarmente)
		bean.setTexts( getTextService().list( attributeId = arguments.record.attribute_id ) )
		bean.setStatus( getStatusService().get( arguments.record.status_id ) );
		bean.setValues( getAttributeValueService().list( attributeId = arguments.record.attribute_id ) );

		var categories = super.getCategoriesBeanByIds( arguments.record.categories );
		bean.setCategories( categories );

		return bean;
	}

}
