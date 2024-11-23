component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.LineCategoryDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="textService" type="com.apirone.core.model.service.TextService";

    public com.apirone.core.model.bean.LineCategory function get(
    		required String lineCategoryId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.lineCategoryId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	       return  cache.data;
	    
	    }
	    
		var bean = build( arguments.lineCategoryId );
		cm.put( key, bean );
        
		return bean;

	}
	
    public com.apirone.core.model.bean.Result function search(
				 String str,
				 String lineId,
		required Numeric limit = 20,
		required Numeric offset = 0,
		required Array orderBy = [ { field="category.code" } ],
    ){

		var rows = [];

        var result = super.getResult()

		arguments["orderby"] = super.createOrderBy( arguments["orderby"] );

    	var records = getDao().find( argumentCollection=arguments );

	    for( var record in records ){

	    	rows.add( 
	    		get( lineCategoryId = record.line_category_id )
	    	);

	    }

		result.setTotal( records.total );
		result.setCount( records.recordCount() );
		result.setData( rows );

        return result;

	}

    public com.apirone.core.model.bean.LineCategory[] function list(
			required Array orderBy = [ { field='lineCategory.code' } ],
					 String str,
					 String productId
		){

		arguments["limit"] = -1;

		return search( argumentCollection = arguments ).getData();

	}

	public String function create(
            required com.apirone.core.model.bean.LineCategory category
		){		
	
		if ( !Len( arguments.category.getCode() ) ) {
			throw( type="apirone.errors.createLineCategory.codeNotProvided", message="Code required" );
		};

	
		if ( !Len( arguments.category.getTexts() ) ) {
			throw( type="apirone.errors.createLineTexts.noTexsProvided", message="At least one description required" );
		};		

		transaction{

			var newId = getDao().insert( arguments.category );

			for ( var text in arguments.category.getTexts() ) {

				var entity = super.bean("Entity");

				entity.setKey( "lineCategory.id" );
				entity.setValue( newId );

				text.setEntity( entity );

			}

			getTextService().bulkCreate( arguments.category.getTexts() );

		}

		return newId;


        return getDao().insert( arguments.LineCategory );

	}

	public String function update(
            required com.apirone.core.model.bean.Category category
		){		
	
		if ( !Len( arguments.category.getId() ) ) {
			throw( type="apirone.errors.updateLineCategory.IdNotProvided", message="ID required" );
		};

		if ( !Len( arguments.category.getName() ) ) {
			throw( type="apirone.errors.updateLineCategory.NameNotProvided", message="Name required" );
		};

        var id = getDao().update( LineCategory = arguments.LineCategory );
		
		var cm = getCacheManager();
		
        cm.remove( arguments.LineCategory.getId() );

		return id;

	}

	public Boolean function delete(
			required String lineCategoryId
		){
	
		var result = getDao().delete( arguments.lineCategoryId );

		var cm = super.getCacheManager();

		cm.remove( getCachekey( arguments.lineCategoryId ) );

		return result;

	}


	public Boolean function nameExists(
			required String name
		){
			
		var result = getDao().readByName( arguments.name )
	
		return BooleanFormat(  result.RecordCount );

	}

    /*
    	private methods
	*/

	private com.apirone.core.model.bean.LineCategory function build(
    		required String lineCategoryId
    	){

	    var record = getDao().read( arguments.lineCategoryId );

	    if( record.RecordCount ) { 

          	var bean = super.bean( "LineCategory" );

            bean.setId( record.line_category_id );
            bean.setCode( record.code );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setCreatedAt( record.created_at );

            bean.setTexts( getTextService().list( lineCategoryId = record.line_category_id ) );

			return bean;
			
	    }

    	return NullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "LineCategory_#arguments.id#";

  	}

}
