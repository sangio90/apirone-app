component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="ReportDAO";
	property name="statusService" inject="StatusService";
	property name="lookupService" inject="LookupService";

	public com.apirone.core.model.bean.Report function get( required String reportId ){
		return build( arguments.reportId );
	}

	public String function create( required com.apirone.core.model.bean.Report report ){
		var id = getDao().insert( argumentCollection = arguments );

		return id;
	}

	public Boolean function delete( required String reportId ){
		var result = getDao().delete( arguments.reportId );

		return result;
	}

	public com.apirone.core.model.bean.Result function search(
		String email,
		required Numeric limit  = 50,
		required Numeric offset = 0
	){
		var rows   = [];
		var result = super.getResult();

		// Il search() del DAO ora restituisce tutte le colonne: si possono usare gli ID per getMany()
		var records = getDao().search( argumentCollection = arguments );

		// Raccoglie gli ID e carica i bean in blocco con getMany()
		var ids = [];
		for ( var record in records ) {
			ids.add( record.report_id );
		}

		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

		// Itera i record originali per preservare l'ordinamento
		for ( var record in records ) {
			rows.add( beanMap[ record.report_id ] );
		}

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	/**
	 * Recupera in batch più Report dato un array di ID.
	 * Restituisce uno Struct chiave = reportId, valore = bean Report.
	 * Precarica lo Status in batch locale per evitare il problema N+1.
	 *
	 * @ids Array di reportId
	 * @return Struct mappato per reportId -> Report
	 */
	public Struct function getMany( required Array ids ){
		var records  = getDao().readByIds( ids = arguments.ids );
		var map      = {};
		var statuses = {};

		for ( var record in records ) {
			var bean = super.bean( "Report" );

			// Campi diretti dal record
			bean.setId( record.report_id );
			bean.setName( record.report );
			bean.setExampleData( record.example_data );
			bean.setExampleFile( record.example_file );
			bean.setFileName( record.file_name );

			// Status: cached localmente
			if ( !StructKeyExists( statuses, record.status_id ) ) {
				statuses[ record.status_id ] = getStatusService().get( record.status_id );
			}
			bean.setStatus( statuses[ record.status_id ] );

			map[ bean.getId() ] = bean;
		}

		return map;
	}

	/**
	 * @private
	 */
	private com.apirone.core.model.bean.Report function build( required String reportId ){
		var record = getDao().read( reportId = arguments.reportId );

		if ( record.RecordCount ) {
			return buildFromSearchRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Report a partire da una riga della query.
	 */
	private com.apirone.core.model.bean.Report function buildFromSearchRow( required any record ){
		var bean = super.bean( "Report" );

		// Campi diretti dal record
		bean.setId( record.report_id );
		bean.setName( record.report );
		bean.setExampleData( record.example_data );
		bean.setExampleFile( record.example_file );
		bean.setFileName( record.file_name );

		// Entity collegata (Status è un lookup leggero)
		bean.setStatus( getStatusService().get( record.status_id ) );

		return bean;
	}

}
