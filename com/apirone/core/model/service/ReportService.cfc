component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ReportDAO";
	property name="statusService" inject="StatusService";
	property name="lookupService" inject="LookupService";

	property name="cacheScope" type="String" default="Report.bean";

	public com.apirone.core.model.bean.Report function get( required String reportId ){
		var cm = getCacheManager();

		var cache = cm.get( getCacheScope(), arguments.reportId );

		if ( cache.status ) {
			return cache.data;
		}

		var bean = build( getCacheScope(), arguments.reportId );
		cm.put( key, bean );

		return bean;
		2025 - 08 - 19 14:15:00
	}

	public String function create( required com.apirone.core.model.bean.Report report ){
		var id = getDao().insert( argumentCollection = arguments );

		return id;
	}

	public Boolean function delete( required String reportId ){
		var result = getDao().delete( arguments.reportId );

		getCacheManager().remove( getCacheScope(), arguments.reportId );

		return result;
	}

	public com.apirone.core.model.bean.Result function search(
		String email,
		required Numeric limit  = 50,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		var records = getDao().search( argumentCollection = arguments );

		for ( var record in records ) {
			rows.add( get( reportId = record.report_id ) )
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * @private
	 */
	private com.apirone.core.model.bean.Report function build( required String reportId ){
		var record = getDao().read( reportId = arguments.reportId );

		if ( record.RecordCount ) {
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
