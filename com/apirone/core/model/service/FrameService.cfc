component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FrameDAO";
	property name="statusService" inject="StatusService";
	property name="lookupService" inject="LookupService";
	property name="frameCellService" inject="FrameCellService";

	public com.apirone.core.model.bean.Frame function get( required String frameId ){
		return build( arguments.frameId );
	}

	public Array function list(){
		arguments[ "limit" ] = -1;

		return search( argumentCollection = arguments ).getData();
	}


	public com.apirone.core.model.bean.Result function search(
		String str,
		String statusId,
		required Numeric limit  = 20,
		required Numeric offset = 0,
		required Array orderBy  = [ { field = "frame.code", desc = "asc" } ]
	){
		var rows   = [];
		var result = super.getResult();

		arguments[ "orderby" ] = super.createOrderBy( arguments[ "orderby" ] );

		// Primo passaggio: il find() restituisce solo gli ID (più il totale per paginazione)
		var records = getDao().find( argumentCollection = arguments );

		// Raccoglie tutti gli ID e carica i record in blocco con una sola query
		var ids     = [];
		records.each( function( r ){
			ids.append( r.frame_id ); // frame_id già castato a varchar dal find()
		} );

		var beanMap = {};

		if ( ArrayLen( ids ) ) {
			var allRecords = getDao().readByIds( ids );
			allRecords.each( function( r ){
				beanMap[ r.frame_id ] = buildFromRow( r );
			} );
		}

		// Ricostruisce le righe nell'ordine del find() originale
		records.each( function( r ){
			rows.add( beanMap[ r.frame_id ] );
		} );

		result.setData( rows );
		result.setCount( Val( records.recordcount ) );
		result.setTotal( Val( records.total ) );

		return result;
	}

	public String function create( required com.apirone.core.model.bean.Frame frame ){

		var newId = getDao().insert( arguments.frame );

		if( ( !IsNull( arguments.frame.getCells() ) ) ) {

			for( var cell in arguments.frame.getCells() ) {
				cell.setFrameId( newId );
				getFrameCellService().create( cell );
			}

		}

		return newId;
	}

	public String function update( required com.apirone.core.model.bean.Frame frame ){

		transaction {

			getDao().update( arguments.frame );

			getFrameCellService().deleteByFrameId( arguments.frame.getId() );

			if( ( !IsNull( arguments.frame.getCells() ) ) ) {

				for( var cell in arguments.frame.getCells() ) {
					cell.setFrameId( frame.getId() );
					getFrameCellService().create( cell );
				}

			}

		}

		return arguments.frame.getId();
	}

	public Boolean function codeExists( required String code, String excludedId = "" ){
		var record = getDao().readByCode( arguments.code );

		if (
			record.recordCount
			&& record.frame_id != arguments.excludedId
		) {
			return record.code == arguments.code;
		}

		return false;
	}

	/**
	 * @auditEvent frame.deleted
	 * @auditMessage frame [@frameId@] deleted
	 * @auditPayload { "id": "@frameId@" }
	 */
	public com.apirone.core.model.bean.Outcome function delete( required String frameId ){
		var outcome = super.bean( "Outcome" );

		var obj = get( arguments.frameId );

		outcome.setData( { frameId = arguments.frameId } );

		transaction {
			try {
				var result = getDao().delete( arguments.frameId );
				outcome.setData( { "deletedCount" = result } )

				// super.logAction( type = "frame.DELETED", message = "frame [#arguments.frameId#] deleted" );
			} catch ( any error ) {
				outcome.setError( error );
				outcome.setStatus( "ERROR" );
				outcome.setType( "ApirOne.error.CannotDeleteFrame" );
				outcome.setMessage( "Cannot delete frame [#arguments.frameId#]" );
			}
		}

		return outcome;
	}


	/*
    	private method
	*/

	/**
	 * Costruisce un bean Frame a partire dall'ID, effettuando la lettura dal DB.
	 */
	private com.apirone.core.model.bean.Frame function build( required String frameId ){
		var record = getDao().read( arguments.frameId );

		if ( record.recordCount ) {
			return buildFromRow( record );
		}

		return NullValue();
	}

	/**
	 * Costruisce un bean Frame a partire da una riga della query.
	 * Utilizzato sia da build() (record singolo) che da search() (iterazione batch).
	 * Le sub-entity (orientation, cellOrientation, status, cells) sono caricate con chiamate individuali.
	 */
	private com.apirone.core.model.bean.Frame function buildFromRow( required any record ){
		var bean = super.bean( "Frame" );

		// Campi diretti dal record
		bean.setId( record.frame_id );
		bean.setName( record.frame );
		bean.setCode( record.code );
		bean.setCreatedAt( record.created_at );

		// Entity collegate (caricate singolarmente)
		bean.setOrientation( getLookupService().get( "orientation", record.orientation_id ) );
		bean.setCellOrientation( getLookupService().get( "orientation", record.cell_orientation_id ) );
		bean.setStatus( getStatusService().get( record.status_id ) );

		bean.setCells( getFrameCellService().list( record.frame_id ) );

		return bean;
	}

}
