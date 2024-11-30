component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.CombinationItemDAO";
	property name="CombinationService" type="com.apirone.core.model.service.CombinationService";
	property name="attributeService" type="com.apirone.core.model.service.AttributeService";
	property name="attributeValueService" type="com.apirone.core.model.service.AttributeValueService";
	property name="statusService" type="com.apirone.core.model.service.StatusService";

    public com.apirone.core.model.bean.CombinationItem function get(
    		required String combinationItemId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.combinationItemId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.combinationItemId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.CombinationItem[] function getTree(
            required String combinationId,
            required Numeric parentId=NullValue(), 
            required String level=1, 
            required String orderBy=""
    ) {
		
        var result = [];

        var combinationId = arguments.combinationId;

        var items = list( 
            combinationId = arguments.combinationId,
            parentId = arguments.parentId
        )

        var thisLevel = arguments.level;

        var n = 1;

        for( var item in items ) {

            var thisOrderBy = "#arguments.orderBy#.#n#";

            item.setLevel( arguments.level );
            //item.setOrderBy( thisOrderBy );

            result.add( item );


            //abort;

            var rows = getTree( combinationId, item.getId(), thisLevel+1, thisOrderBy );

            cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# - [ combId:#combinationId#, itemId:#item.getId()#, level:#thisLevel+1#, itemLen:#items.len()#, orderBy:#thisOrderBy# ] #rows.len()#");

            result = result.merge( rows );

            n++;

        }

     
		
		return result;
	
	}


	public com.apirone.core.model.bean.CombinationItem[] function list(
        required String combinationId
    ) {
		arguments["limit"] = -1;
		
		return search(argumentCollection = arguments).getData();
	
	}


    public com.apirone.core.model.bean.Result function search(
            String lineId
        ){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( 
                get( record.combination_item_id ) 
            );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.recordcount ) );

        return result;

    }

    public com.smartvillage.core.model.bean.Outcome function delete(
			required String combinationId
		){

		var outcome = super.bean("Outcome");

        var obj = get( arguments.combinationId );

		outcome.setData( { combinationId: arguments.combinationId } );

		transaction {
		
		    try  {

                var cm = getCacheManager();

                getDao().delete( arguments.combinationId );
        
                cm.remove( "combination_#obj.getId()#" );
                
			} catch ( any error ) {

				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteEvent" );
				outcome.setMessage( "Cannot delete combination [#arguments.combinationId#]" );
				
			}
			
		}

		return outcome;

	}

	public String function create(
			required com.apirone.core.model.bean.CombinationItem combinationItem
		){

		var newId = getDao().insert( arguments.combinationItem );

		return newId;

	}



    /*
    	private method
	*/

	private com.apirone.core.model.bean.CombinationItem function build(
    		required String combinationItemId
    	){

	    var record = getDao().read( arguments.combinationItemId );

	    if( record.recordCount ) { 

            var bean = super.bean( "CombinationItem" );

            bean.setId( record.combination_item_id );
            bean.setCombinationId( record.combination_id );
			bean.setCreatedAt( record.created_at );
			bean.setParent( get( record.parent_id ) );
			bean.setOrderBy( record.orderby );

            bean.setStatus( getStatusService().get( record.status_id ) );

			var attributeValue = getAttributeValueService().get( record.attribute_value_id );
            
			bean.setAttributeValue( attributeValue );
            bean.setAttribute( getAttributeService().get( attributeValue.getAttributeId() ) );
			
            return bean;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "combinationItem_#arguments.id#";

  	}

}
