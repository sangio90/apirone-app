component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ProductCategoryDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="textService" type="com.apirone.core.model.service.TextService";

    public com.apirone.core.model.bean.ProductCategory function get(
    		required String ProductCategoryId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.ProductCategoryId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	       return  cache.data;
	    
	    }
	    
		var bean = build( arguments.ProductCategoryId );
		cm.put( key, bean );
        
		return bean;

	}
	
    public com.apirone.core.model.bean.Result function search(
				 String str,
				 String lineId,
		required Numeric limit = 20,
		required Numeric offset = 0,
		required Array orderBy = [ { field="productCategory.code" } ],
    ){

		var rows = [];

        var result = super.getResult()

		arguments["orderby"] = super.createOrderBy( arguments["orderby"] );

    	var records = getDao().find( argumentCollection=arguments );

	    for( var record in records ){

	    	rows.add( 
	    		get( ProductCategoryId = record.product_category_id )
	    	);

	    }

		result.setTotal( records.total );
		result.setCount( records.recordCount() );
		result.setData( rows );

        return result;

	}

    public com.apirone.core.model.bean.ProductCategory[] function list(
			required Array orderBy = [ { field='ProductCategory.code' } ],
					 String str,
					 String productId
		){

		arguments["limit"] = -1;

		return search( argumentCollection = arguments ).getData();

	}

	public String function create(
            required com.apirone.core.model.bean.ProductCategory ProductCategory
		){		
	
		if ( !Len( arguments.ProductCategory.getCode() ) ) {
			throw( type="apirone.errors.createProductCategory.codeNotProvided", message="Code required" );
		};
	
		if ( !Len( arguments.ProductCategory.getTexts() ) ) {
			throw( type="apirone.errors.createLineTexts.noTexsProvided", message="At least one description required" );
		};		

		transaction{

			var newId = getDao().insert( arguments.ProductCategory );

			for ( var text in arguments.ProductCategory.getTexts() ) {

				var entity = super.bean("Entity");

				entity.setKey( "ProductCategory.id" );
				entity.setValue( newId );

				text.setEntity( entity );

			}

			getTextService().bulkCreate( arguments.ProductCategory.getTexts() );

		}

		return newId;

	}

	public String function update(
            required com.apirone.core.model.bean.ProductCategory ProductCategory
		){		
	
		if ( !Len( arguments.ProductCategory.getCode() ) ) {
			throw( type="apirone.errors.createProductCategory.codeNotProvided", message="Code required" );
		};
	
		if ( !Len( arguments.ProductCategory.getTexts() ) ) {
			throw( type="apirone.errors.createLineTexts.noTexsProvided", message="At least one description required" );
		};		
	
		var cm = getCacheManager();

		var id = getDao().update( arguments.ProductCategory );

		for ( var text in arguments.ProductCategory.getTexts() ) {

			var entity = super.bean("Entity");

			entity.setKey( "ProductCategory.id" );
			entity.setValue( id );

			text.setEntity( entity );

			getTextService().update( text );

		}

        cm.remove( getCacheKey( arguments.ProductCategory.getId() ) );

		return id;

	}

	public com.apirone.core.model.bean.Outcome function delete(
		required String productCategoryId
	){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.productCategoryId );

		outcome.setData( { productCategoryId = arguments.productCategoryId } );

		transaction {
			try {
				var result = getDao().delete( arguments.productCategoryId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( getCacheKey( arguments.productCategoryId ) );

			} catch ( any error ) {
				
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteProductCategory" );
				outcome.setMessage( "Cannot delete product category [#arguments.productCategoryId#]" );
			
			}
		}

		return outcome;
	}	

	public Boolean function codeExists(
		required String code,
		String excludedId = ""
	){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.product_category_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}


    /*
    	private methods
	*/

	private com.apirone.core.model.bean.ProductCategory function build(
    		required String ProductCategoryId
    	){

	    var record = getDao().read( arguments.ProductCategoryId );

	    if( record.RecordCount ) { 

          	var bean = super.bean( "ProductCategory" );

            bean.setId( record.product_category_id );
            bean.setCode( record.code );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setCreatedAt( record.created_at );

            bean.setTexts( getTextService().list( ProductCategoryId = record.product_category_id ) );

			return bean;
			
	    }

    	return NullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "ProductCategory_#arguments.id#";

  	}

}
