component extends="com.apirone.core.model.service.AbsService" accessors="true" {

    property name="dao" type="com.apirone.core.model.dao.CommissionDAO";
    property name="productCategoryService" type="com.apirone.core.model.service.ProductCategoryService";

    public com.apirone.core.model.bean.Account function get(
    		required String accountId
    	){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.accountId );

	   	var cache = cm.get( key );

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
        var account = build( arguments.accountId );
        cm.put( key, account );
        
		return account;

    }

	public String function create(
			required com.apirone.core.model.bean.Account account
		){


		var id = getDao().insert( argumentCollection = arguments );

		return id;

	}

	public Boolean function delete(
			required String accountId
		){
	
		var result = getDao().delete( arguments.accountId );

		getCacheManager().remove( getCacheKey( arguments.accountId ) );

		return result;

	}

	public com.apirone.core.model.bean.Result function search(
				 String email,
		required Numeric limit=50,
		required Numeric offset=0
	){

		var rows = [];
		var result = super.getResult();

		var records = getDao().search( argumentCollection=arguments );

		for( var record in records ){

			rows.add( 
				get( accountId = record.account_id )
			)

		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;

	}

    /**
     * @private
     */
  	private com.apirone.core.model.bean.Account function build(
    		required String commissioneId
    	){

	    var record = getDao().read( commissioneId = arguments.commissioneId );

		var account = nullValue();

	    if( record.RecordCount ) { 

	    	var account = super.bean( "Account" );

		    account.setId( record.company_category_id.toString() );
			account.setCategory( record.api_key.toString() );
			account.setValue( record.commission );

	    } 
			
		return account;
		
  	}

  	private String function getCacheKey( required String id ) {

  		return "Commission_#arguments.id#";

  	}

}
