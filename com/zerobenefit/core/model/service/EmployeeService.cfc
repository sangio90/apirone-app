component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.EmployeeDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="locationService" type="com.apirone.core.model.service.LocationService";
	property name="accountService" type="com.apirone.core.model.service.AccountService";
	property name="employeeService" type="com.apirone.core.model.service.EmployeeService";
	property name="walletService" type="com.apirone.core.model.service.WalletService";

    public com.apirone.core.model.bean.Employee function get(
    		required String employeeId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.employeeId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var employee = build( arguments.employeeId );
		cm.put( key, employee );
        
		return employee;

	}

	public String function create(
            required com.apirone.core.model.bean.Employee employee
		){		

		transaction {
			
			var accountId = getAccountService()
								.create(account = arguments.employee.getAccount());

			arguments.employee.getAccount().setId(accountId);
			
			var id = getDao().insert( 
                employee = arguments.employee 
            );

			var entity = super.bean('Entity');
			entity.setType( "E" );
			entity.setId( id );

			getLocationService()
				.create( entity = entity,  location = arguments.employee.getLocation() );
			
			return id;
		}

	}

	public String function fiscalCodeExists( required String fiscalCode ){		

		transaction {
			
			var accountId = getAccountService()
								.create(account = arguments.employee.getAccount());

			arguments.employee.getAccount().setId(accountId);
			
			var id = getDao().insert( 
                employee = arguments.employee 
            );

			var entity = super.bean('Entity');
			entity.setType( "E" );
			entity.setId( id );

			getLocationService()
				.create( entity = entity,  location = arguments.employee.getLocation() );
			
			return id;
		}

	}

	public String function update(
            required com.apirone.core.model.bean.Employee employee
		){		

        transaction {

			var id = getDao().update( 
				employee = arguments.employee
			);

			getLocationService()
				.update( location = arguments.employee.getLocation() );
					
			getCacheManager()
				.remove( getCachekey( id ) );

			return id;
		}

	}

	public Boolean function delete(
			required String employeeId
		){
	
		var result = getDao().delete( arguments.employeeId );
        getCacheManager().remove( getCachekey( arguments.employeeId ) );

		return result;

	}

	public Boolean function fiscalCodeExists(
		required String fiscalCode
	) {
		
		var rows = list( argumentCollection = arguments ).getData();

		return !isNull( rows[1] )
		
	}

	public com.apirone.core.model.bean.Employee function getByFiscalCode(
		required String fiscalCode
	) {
		var rows = list( argumentCollection = arguments ).getData();

		return rows[1];
		
	}

	public com.apirone.core.model.bean.Result function list(
		String fiscalCode
	) {
		arguments['limit'] = -1;
		return search(argumentCollection = arguments)
	}

	public com.apirone.core.model.bean.Result function search(
		required Numeric limit = 20,
		required Numeric offset = 0,
		         String fiscalCode,
	) {

		var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			
			rows.add( get( employeeId = record.employee_id ) );
		
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

	}


    /*
    	private method
	*/

	private com.apirone.core.model.bean.Employee function build(
    		required String employeeId
    	){

	    var record = getDao().read( arguments.employeeId );

		var employee = super.bean( "Employee" );

	    if( record.RecordCount ) { 

            employee.setId( record.employee_id.toString() );
            employee.setName( record.name );
            employee.setSurname( record.surname );
			employee.setFiscalCode( record.fiscal_code );
            employee.setPhone( record.phone );
			employee.setAccount( getAccountService().get( accountId = record.account_id ) );
			employee.setLocation( getLocationService().list( employeeId = record.employee_id ).getData()[1] );
			employee.setStatus( getStatusService().get( record.status_id ) );
			employee.setWallet( getWalletService().get( record.employee_id ) );

	    }

		return employee;

  	}

  	private String function getCacheKey( required String id ) {

  		return "Employee_#arguments.id#";

  	}

}
