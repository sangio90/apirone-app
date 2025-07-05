component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.CompanyDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="locationService" type="com.apirone.core.model.service.LocationService";
	property name="accountService" type="com.apirone.core.model.service.AccountService";
	property name="companyTypeService" type="com.apirone.core.model.service.CompanyTypeService";
	
	property name="cacheScope" type="String" default="Company.bean";

    public com.apirone.core.model.bean.Company function get(
    		required String companyId
        ){

    	var cm = getCacheManager();

	   	var cache = cm.get( getCacheScope(), arguments.companyId ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 

		var company = build( arguments.companyId );

		cm.put( getCacheScope(), arguments.companyId, company );
        return company;

	}

	public Boolean function vatExists(
		required String vat
	) {
		var companies = list( argumentCollection = arguments ).getData();

		return !isNull( companies[1] )
		
	}

	public com.apirone.core.model.bean.Result function list(
		String vat
	) {
		arguments["limit"] = -1;
		return search(argumentCollection = arguments)
	}


	public com.apirone.core.model.bean.Result function search(
				 String vat,
		required Numeric limit = 20,
		required Numeric offset = 0
	) {

		var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( companyId = record.company_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

	}

	public String function create(
            required com.apirone.core.model.bean.Company company
		){		

		if ( vatExists( arguments.company.getVat() ) ) {
			throw( type="apirone.VatExits", message="Vat [#arguments.company.getVat()#] exists" );
		}

		transaction {

			var accountId = getAccountService()
								.create(account = arguments.company.getAccount());

			arguments.company.getAccount().setId( accountId );
			
			var id = getDao().insert( 
                company = arguments.company 
            );
			
			var entity = super.bean('Entity');

			entity.setType( "C" );
			entity.setId( id );

			getLocationService()
				.create( entity = entity, location = arguments.company.getLocation() );
			
			return id;
		}

	}

	public String function update(
            required com.apirone.core.model.bean.Company company
		){		

        transaction {

			var id = getDao().update( 
				company = arguments.company
			);

			getLocationService()
				.update(  location = arguments.company.getLocation() );
					
			getCacheManager()
				.remove( getCacheScope(), id );

			return id;
		}

	}

	public Boolean function delete(
			required String companyId
		){

		var result = getDao().delete( arguments.companyId );
        
		getCacheManager().remove( getCacheScope(), arguments.companyId );

		return result;

	}

    /*
    	private method
	*/

	private com.apirone.core.model.bean.Company function build(
    		required String companyId
    	){

	    var record = getDao().read( arguments.companyId );

	    if( record.RecordCount ) { 

			var company = super.bean( "Company" );

			var types = [];

            company.setId( record.company_id.toString() );
            company.setName( record.company );
            company.setVat( record.vat );
            company.setContact( record.contact );
            company.setPhone( record.phone );
            company.setCode( record.code );
			company.setLocation( getLocationService().list( companyId = record.company_id ).getData()[1] );
			company.setAccount( getAccountService().get( accountId = record.account_id.toString() ) );

			DeserializeJSON( record.types.getValue() )
				.each( function( typeId ) {
					types.push( getCompanyTypeService().get( typeId ) );
				});

			company.setTypes( types );
			company.setStatus( getStatusService().get( record.status_id ) );

			return company;

	    }

		return nullValue();

  	}

}
