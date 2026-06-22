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

		var beanMap = ArrayLen( ids ) ? getMany( ids ) : {};

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
	 * Recupera in batch più Frame dato un array di ID.
	 * Restituisce uno Struct chiave = frameId, valore = bean Frame.
	 * Precarica FrameCell, orientation/cellOrientation e status in batch per evitare il problema N+1.
	 *
	 * @ids Array di frameId
	 * @return Struct mappato per frameId -> Frame
	 */
	public Struct function getMany( required Array ids ){
		var records = getDao().readByIds( ids = arguments.ids );
		var map     = {};

		// Cache locali per orientation (LookupService è in-memory)
		var orientations = {};

		// Cache locale per status
		var statuses = {};

		// Precarica i FrameCell in batch: raccoglie tutti i frame_id
		var frameIds = arguments.ids;
		var cellMap  = {};
		if ( ArrayLen( frameIds ) ) {
			var cellRecords = getFrameCellService().getDao().readByFrameIds( frameIds = frameIds );
			for ( var cr in cellRecords ) {
				var frameId = cr.frame_id;
				if ( !StructKeyExists( cellMap, frameId ) ) {
					cellMap[ frameId ] = [];
				}
				var cellBean = super.bean( "FrameCell" );
				cellBean.setId( cr.frame_cell_id );
				cellBean.setRow( cr.row );
				cellBean.setCol( cr.col );
				cellBean.setWidth( cr.width );
				cellBean.setHeight( cr.height );
				cellBean.setFrameId( cr.frame_id );
				cellBean.setCreatedAt( cr.created_at );
				cellBean.setType( getLookupService().get( "frameCellType", cr.type_id ) );
				cellBean.setOrientation( getLookupService().get( "orientation", cr.orientation_id ) );
				ArrayAppend( cellMap[ frameId ], cellBean );
			}
		}

		for ( var record in records ) {
			var bean = super.bean( "Frame" );

			// Campi diretti dal record
			bean.setId( record.frame_id );
			bean.setName( record.frame );
			bean.setCode( record.code );
			bean.setCreatedAt( record.created_at );

			// Orientation: LookupService in-memory, cached localmente
			if ( !StructKeyExists( orientations, record.orientation_id ) ) {
				orientations[ record.orientation_id ] = getLookupService().get( "orientation", record.orientation_id );
			}
			bean.setOrientation( orientations[ record.orientation_id ] );

			// CellOrientation: LookupService in-memory, cached localmente
			if ( !StructKeyExists( orientations, record.cell_orientation_id ) ) {
				orientations[ record.cell_orientation_id ] = getLookupService().get( "orientation", record.cell_orientation_id );
			}
			bean.setCellOrientation( orientations[ record.cell_orientation_id ] );

			// Status: cached localmente
			if ( !StructKeyExists( statuses, record.status_id ) ) {
				statuses[ record.status_id ] = getStatusService().get( record.status_id );
			}
			bean.setStatus( statuses[ record.status_id ] );

			// FrameCell: dalla mappa pre-caricata
			if ( StructKeyExists( cellMap, record.frame_id ) && ArrayLen( cellMap[ record.frame_id ] ) ) {
				bean.setCells( cellMap[ record.frame_id ] );
			}

			map[ record.frame_id ] = bean;
		}

		return map;
	}

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
