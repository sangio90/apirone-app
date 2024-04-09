component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.CardDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="companyService" type="com.apirone.core.model.service.CompanyService";

    public com.apirone.core.model.bean.Card function get(
    		required String cardId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.cardId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var card = build( arguments.cardId );
		cm.put( key, card );
	    return card;

	}

	public String function create(
            required com.apirone.core.model.bean.Card card
		){		

		var company = getCompanyService().get( arguments.card.getCompany().getId() );

		arguments.card.setId( 
			generateId( company.getCode() )
		);

        return getDao().insert( 
				card = arguments.card 
			);

	}

	public String function assign(
		required String employeeId,
		required String cardId
	) {

		var card = get( arguments.cardId );
		card.setEmployeeId( arguments.employeeId );
		card.setAssignedAt( now() );

		return update(card);

	}

	public com.apirone.core.model.bean.Result function list(
		String employeeId
	) {
		arguments['limit'] = -1;
		return search(argumentCollection = arguments)
	}


    public com.apirone.core.model.bean.Result function search(
			required Numeric limit = 20,
			required Numeric offset = 0,
			String employeeId
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( cardId = record.card_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }

	public String function update(
            required com.apirone.core.model.bean.Card card
		){		

        var id = getDao().update( 
			card = arguments.card
		);
				
        getCacheManager().remove( getCachekey( arguments.card.getId() ) );

		return id;

	}

	public Boolean function delete(
			required String cardId
		){
	
		var result = getDao().delete( arguments.cardId );
        
		getCacheManager().remove( getCachekey( arguments.cardId ) );

		return result;

	}

	public Boolean function idExists(
		required String cardId
	) {

		return !isNull( get( arguments.cardId ) );

	}

    /*
    	private method
	*/

	private com.apirone.core.model.bean.Card function build(
    		required String cardId
    	){

	    var record = getDao().read( arguments.cardId );


	    if( record.RecordCount ) { 

			var card = super.bean( "Card" );

            card.setId( record.card_id );
            card.setEmissionAt( record.emission_at );
            card.setExpirationAt( record.expiration_at );
            card.setAssignedAt( record.assigned_at );
			card.setCompany( getCompanyService().get( record.company_id ) );
            card.setEmail( record.email );
			card.setPhone( record.phone );
            card.setEmployeeId( record.employee_id.toString() );
			card.setAmount( record.amount );
			card.setAmountSpent( record.amount_spent );
			card.setStatus( getStatusService().get( record.status_id ) );

			return card;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Card_#arguments.id#";

  	}

	private String function generateId(
            required String code
		){		

		var uuid = Right( CreateUUID(), 6 );
		var id = UCase("#uuid##code#"); 

		if ( idExists(id) ) {
		
			return generateId( code = arguments.code );

		}
						
		return id;

	}


}
