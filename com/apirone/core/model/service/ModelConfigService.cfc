component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ModelConfigDAO";
	property name="modelService" inject="ModelService";
	property name="productCategoryService" inject="ProductCategoryService";
	property name="lineService" inject="LineService";
	property name="textService" inject="TextService";

	public com.apirone.core.model.bean.ModelConfig function get( required String modelConfigId ){
		return build( arguments.modelConfigId );
	}

	public String function create( required com.apirone.core.model.bean.ModelConfig modelConfig ){
		var newId = getDao().insert( arguments.modelConfig );
		return newId;
	}

	public String function update( required com.apirone.core.model.bean.ModelConfig modelConfig ){
		getDao().update( arguments.modelConfig );

		return arguments.modelConfig.getId();
	}


	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String modelId,
		Number productCategoryId,
		String lineId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = []
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids = [];
		for ( var record in records ) {
			ids.append( record.model_config_id );
		}

		// Costruisce tutti i bean in batch con getMany() ottimizzato (evita N+1)
		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Ricostruisce le righe nell'ordine del find() originale
		for ( var record in records ) {
			rows.add( beanMap[ record.model_config_id ] );
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * Recupera in batch più ModelConfig dato un array di ID.
	 * Restituisce uno Struct chiave = modelConfigId, valore = bean ModelConfig.
	 * Precarica Model, ProductCategory e Line in batch per evitare il problema N+1.
	 *
	 * @ids Array di modelConfigId
	 * @return Struct mappato per modelConfigId -> ModelConfig
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Raccoglie tutti gli ID delle FK da precaricare in batch
		var modelIds    = [];
		var categoryIds = [];
		var lineIds     = [];

		for ( var record in records ) {
			if ( !IsNull( record.model_id ) ) {
				modelIds.append( record.model_id );
			}
			if ( !IsNull( record.product_category_id ) ) {
				categoryIds.append( record.product_category_id );
			}
			if ( !IsNull( record.line_id ) ) {
				lineIds.append( record.line_id );
			}
		}

		// Precarica le entity FK con getMany() esistenti (1 query ciascuna)
		var modelMap = {};
		if ( ArrayLen( modelIds ) ) {
			modelMap = getModelService().getMany( modelIds );
		}

		var categoryMap = {};
		if ( ArrayLen( categoryIds ) ) {
			categoryMap = getProductCategoryService().getMany( categoryIds );
		}

		var lineMap = {};
		if ( ArrayLen( lineIds ) ) {
			lineMap = getLineService().getMany( lineIds );
		}

		// Costruisce i bean con le mappe pre-caricate
		for ( var record in records ) {
			var bean = super.bean( "ModelConfig" );

			// Campi diretti dal record
			bean.setId( record.model_config_id );
			bean.setHeight( record.height );
			bean.setWidth( record.width );

			// Entity collegate dalle mappe pre-caricate
			if ( StructKeyExists( modelMap, record.model_id ) ) {
				bean.setModel( modelMap[ record.model_id ] );
			}

			if ( StructKeyExists( categoryMap, record.product_category_id ) ) {
				bean.setProductCategory( categoryMap[ record.product_category_id ] );
			}

			if ( StructKeyExists( lineMap, record.line_id ) ) {
				bean.setLine( lineMap[ record.line_id ] );
			}

			map[ record.model_config_id ] = bean;
		}

		return map;
	}


	/*
     	private method
	*/

	private com.apirone.core.model.bean.ModelConfig function build( required String modelConfigId ){
		var record = getDao().read( arguments.modelConfigId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean ModelConfig a partire da una riga del query.
	 * Le sub-entity (Model, ProductCategory, Line) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.ModelConfig function buildFromRow( required any record ){
		var bean = super.bean( "ModelConfig" );

		// Campi diretti dal record
		bean.setId( record.model_config_id );
		bean.setHeight( record.height );
		bean.setWidth( record.width );

		// Entity collegate (caricate singolarmente)
		bean.setModel( getModelService().get( record.model_id ) );
		bean.setProductCategory( getProductCategoryService().get( record.product_category_id ) );
		bean.setLine( getLineService().get( record.line_id ) );

		return bean;
	}

}
