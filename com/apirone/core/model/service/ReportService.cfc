component extends="com.apirone.core.model.service.AbsService" accessors="true" {

    property name="dao" type="com.apirone.core.model.dao.ReportDAO";
    property name="statusService" type="com.apirone.core.model.service.StatusService";
    property name="lookupService" type="com.apirone.core.model.service.LookupService";
    
	property name="scopeCache" type="String" default="Report.bean";

    public com.apirone.core.model.bean.Report function get(
    		required String reportId
    	){

    	var cm = getCacheManager();

	   	var cache = cm.get( getScopeCache(), arguments.reportId ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
        var bean = build( getScopeCache(), arguments.reportId );
        cm.put( key, bean );
        
		return bean;

    }

	public String function create(
			required com.apirone.core.model.bean.Report report
		){


		var id = getDao().insert( argumentCollection = arguments );

		return id;

	}

	public Boolean function delete(
			required String reportId
		){
	
		var result = getDao().delete( arguments.reportId );

		getCacheManager().remove( getScopeCache(), arguments.reportId );

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
				get( reportId = record.report_id )
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
  	private com.apirone.core.model.bean.Report function build(
    		required String reportId
    	){

	    var record = getDao().read( reportId = arguments.reportId );

	    if( record.RecordCount ) { 

	    	var bean = super.bean( "Report" );

		    bean.setId( record.report_id );
		    bean.setName( record.report );
		    bean.setExampleData( record.example_data );
		    bean.setExampleFile( record.example_file );
		    bean.setFileName( record.file_name );
			bean.setStatus( getStatusService().get( record.status_id ) );

			return bean;

	    } 
			
		return NullValue();
		
  	}

}
