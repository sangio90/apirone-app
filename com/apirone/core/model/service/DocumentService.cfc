component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.DocumentDAO";
	property name="statusService" type="com.apirone.core.model.service.StatusService";
	property name="documentItemService" type="com.apirone.core.model.service.DocumentItemService";
	property name="lookupService" type="com.apirone.core.model.service.lookupService";
	property name="employeeService" type="com.apirone.core.model.service.EmployeeService";

    public com.apirone.core.model.bean.Document function get(
    		required String documentId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.documentId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.documentId );
		cm.put( key, bean );
        
		return bean;

	}

	public com.apirone.core.model.bean.Result function list(
		String employeeId,
		Date from,
		Date to,
	) {
		arguments["limit"] = -1;
		return search(argumentCollection = arguments)
	}

    public com.apirone.core.model.bean.Result function search(
			  		 String employeeId,
			  		 Date from,
			  		 Date to,
			required Numeric limit = 20,
			required Numeric offset = 0,
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( documentId = record.document_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }

	public String function create(
            required com.apirone.core.model.bean.Document document
		){	
			
		transaction {

			var id =  getDao().insert( document = arguments.document );

			arguments.document.setId( id );

			if ( !IsNull( arguments.document.getItems() ) ) {

				for ( var item in arguments.document.getItems() ) {

					additem( arguments.document.getId(), item );
	
				}
	
			}
	
			return id.toString();

		}

	}

	public String function update(
		required com.apirone.core.model.bean.Document document
	){		

		transaction {

			return id.toString();
		}

	}

	public String function addItem(
            required String documentId,
			required com.apirone.core.model.bean.DocumentItem documentItem
		){	

			getDocumentItemService().create(
				documentId = arguments.documentId,
				documentItem = arguments.documentItem
			)
	
	}

	public Boolean function removeItem(
		required String documentId,
		required String productCategoryId
	){	

		return getDao()
			.removeItem(
				argumentCollection = arguments
			);

	}

	public Boolean function delete( required String documentId ){
	
		var result = getDao().delete( arguments.documentId );
        getCacheManager().remove( getCachekey( arguments.documentId ) );

		return result;

	}

	
    /*
    	private method
	*/

	private com.apirone.core.model.bean.Document function build(
    		required String documentId
    	){

	    var record = getDao().read( arguments.documentId );

	    if( record.recordCount ) { 

            var document = super.bean( "Document" );

            document.setId( record.document_id.toString() );
            document.setCode( record.code );
			document.setCreatedAt( record.created_at );
			document.setDate( record.created_at );
			document.setEmployee( getEmployeeService().get( record.employee_id ) );

            document.setStatus( getStatusService().get( record.status_id ) );
            document.setType( getLookupService().get( 'documentType', record.type_id ) );

			document.setItems(
				getDocumentItemService()
					.list( documentId = record.document_id.toString() ) 
					.getData()
			);

            return document;

	    }

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "Document_#arguments.id#";

  	}

}
