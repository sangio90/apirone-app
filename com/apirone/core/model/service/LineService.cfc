component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.LineDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="lookupService" type="com.apirone.core.model.service.LookupService";
	property name="ProductCategoryService" type="com.apirone.core.model.service.ProductCategoryService";

    public com.apirone.core.model.bean.Line function get(
    		required String lineId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.lineId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.lineId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Line[] function list() {
		arguments["limit"] = -1;
		
		return search(argumentCollection = arguments).getData();
	
	}


    public com.apirone.core.model.bean.Result function search(){
	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( lineId = record.line_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.recordcount ) );

        return result;

    }

	public String function create(
		required com.apirone.core.model.bean.Line line
	){

		var newId = getDao().insert( arguments.line );

		return newId;
	}

	public String function update(
		required com.apirone.core.model.bean.Line line
	){
		getDao().update( arguments.line );

		var dm = getCacheManager();

		dump(dm);

		dm.remove( getCacheKey ( arguments.line.getId() ) );

		return arguments.line.getId();
	}


	public Boolean function codeExists(
		required String code,
		String excludedId = ""
	){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.line_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}


	public com.apirone.core.model.bean.Outcome function delete(
		required String lineId
	){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.lineId );

		outcome.setData( { lineId = arguments.lineId } );

		transaction {
			try {
				var result = getDao().delete( arguments.lineId );
				outcome.setData( { "deletedCount" = result } )

				getCacheManager().remove( "line_#arguments.lineId#" );

			} catch ( any error ) {
				
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteLine" );
				outcome.setMessage( "Cannot delete line [#arguments.lineId#]" );
			
			}
		}

		return outcome;
	}	


    /*
    	private method
	*/

	private com.apirone.core.model.bean.Line function build(
    		required String lineId
    	){

	    var record = getDao().read( arguments.lineId );

	    if( record.recordCount ) { 

            var bean = super.bean( "Line" );

            bean.setId( record.line_id );
			bean.setCode( record.code );
			bean.setName( record.line );
			bean.setCreatedAt( record.created_at );
			bean.setThickness( getLookupService().get( "thickness", record.thickness_id ) );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setCategory( getProductCategoryService().get( record.line_category_id ) );

            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "line_#arguments.id#";

  	}

}
