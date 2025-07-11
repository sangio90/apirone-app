component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.ProductsDAO";
	property name="SizeService" type="com.apirone.core.model.dao.SizeService";
	property name="LineService" type="com.apirone.core.model.dao.LineService";
	property name="FinishService" type="com.apirone.core.model.dao.FinishService";
	property name="StatusService" type="com.apirone.core.model.dao.StatusService";
	property name="cacheScope" type="String" default="Product.bean";

    public com.apirone.core.model.bean.Product function get(
    		required String productId
        ){

    	var cm = getCacheManager();

	   	var cache = cm.get( getCacheScope(), arguments.productId );

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.productId );
		cm.put( getCacheScope(), arguments.productId, bean );
        
		return bean;

	}

    public com.apirone.core.model.bean.Product function getByParams(
			required String lineId,
			required String finishId,
			required String sizeId
		){

		var record = getDao().find( argumentCollection = arguments );

		if ( record.recordcount == 1) {

			return get( record.product_id );

		}

		return NullValue();

	}

	public com.apirone.core.model.bean.Product[] function list() {
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
			rows.add( get( productId = record.Product_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.recordcount ) );

        return result;

    }

    public com.smartvillage.core.model.bean.Outcome function delete(
			required String productId
		){

		var outcome = super.bean("Outcome");

        var obj = get( arguments.productId );

		outcome.setData( { productId: arguments.productId } );

		transaction {
		
		    try  {

                var cm = getCacheManager();

                getDao().delete( arguments.productId );
        
                cm.remove( getCacheScope(), arguments.productId );
                
			} catch ( any error ) {

				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteEvent" );
				outcome.setMessage( "Cannot delete product [#arguments.productId#]" );
				
			}
			
		}

		return outcome;

	}

    public com.apirone.core.model.bean.Outcome function deleteByParams(
			required String lineId,
			required String finishId,
			required String sizeId
		){

		var outcome = super.bean("Outcome");

        var obj = getByParams( argumentCollection = arguments );

		var combId = obj.getId()

		outcome.setData( { productId: combId } );

		transaction {
		
		    try  {

                var cm = getCacheManager();

                getDao().delete( obj.getId() );
        
                cm.remove( getCacheScope(), arguments.obj.getId() );
                
			} catch ( any error ) {

				/*
					set an error 500?
				*/

				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.CannotDeleteProduct" );
				outcome.setMessage( "Cannot delete product [#combId#]" );
				
			}
			
		}

		return outcome;

	}	


	public String function create(
			required com.apirone.core.model.bean.Product product
		){

		var newId = getDao().insert( arguments.product );

		return newId;

	}



    /*
    	private method
	*/

	private com.apirone.core.model.bean.Product function build(
    		required String productId
    	){

	    var record = getDao().read( arguments.productId );

	    if( record.recordCount ) { 

            var bean = super.bean( "Product" );

            bean.setId( record.product_id );
			bean.setName( "" );
			bean.setCreatedAt( record.created_at );

			bean.setSize( getSizeService().get( record.size_id ) );
			bean.setLine( getLineService().get( record.line_id ) );
			bean.setFinish( getFinishService().get( record.finish_id ) );
			
			//bean.setAttribute( "" );
			
			bean.setStatus( getStatusService().get( record.status_id ) );

            return bean;

	    }

		return nullValue();

  	}

}
