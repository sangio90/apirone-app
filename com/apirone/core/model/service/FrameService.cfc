component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" inject="FrameDAO";
	property name="statusService" inject="StatusService";
	property name="lookupService" inject="LookupService";
	property name="frameCellService" inject="FrameCellService";
	property name="frameBlockService" inject="FrameBlockService";
	property name="modelService" inject="ModelService";

	public com.apirone.core.model.bean.Frame function get( required String frameId ){
		return build( arguments.frameId );
	}

	// Dimensioni fisiche di un mezzofruito. Scala di disegno: 1mm = 1px.
	variables.SLOT_WIDTH_MM  = 11.25;
	variables.SLOT_HEIGHT_MM = 45;

	/**
	 * Disposizione dei blocchi di un'armatura e suo ingombro in millimetri.
	 *
	 * - Gli slot sono numerati con interi progressivi per placca (1..N), uguali in HOR e VER.
	 * - I blocchi scorrono lungo l'asse della placca (orizzontale in HOR, verticale in VER).
	 * - Margini: lungo l'asse di flusso il margine è riferito al blocco precedente
	 *   (LEFT con placca orizzontale, TOP con placca verticale; per il primo blocco
	 *   è riferito al bordo della placca); l'altro margine è sempre riferito al
	 *   bordo della placca.
	 * - I blocchi con orientation_mode fisso (HOR/VER) mantengono il proprio
	 *   orientamento celle in entrambe le viste.
	 * - blockOrientations (JSON {"<order>":"HOR|VER"}): override per singolo
	 *   blocco, usato dai preventivi per ruotare un blocco alla volta.
	 *
	 * Sta qui e non nel controller perché la usano in due: il designer, per
	 * disegnare la placca, e la stampa, che dall'ingombro ricava dove sta la placca
	 * dentro all'anteprima salvata. Due copie di queste regole divergerebbero.
	 *
	 * width/height sono l'ingombro fisico in mm, margini finali destro e inferiore
	 * compresi. Sono 0 per le armature senza blocchi (le legacy su file JSON).
	 */
	public Struct function layout(
		required com.apirone.core.model.bean.Frame frame,
		String orientationId    = "",
		String blockOrientations = ""
	){
		var overrides = {};
		if ( Len( arguments.blockOrientations ) && IsJSON( arguments.blockOrientations ) ) {
			overrides = DeserializeJSON( arguments.blockOrientations );
		}

		var frameOrientationId = arguments.frame.getOrientation().getId();

		var orientationIds = [];
		if ( frameOrientationId == "HAV" ) {
			orientationIds = [ "HOR", "VER" ];
		} else {
			orientationIds = [ frameOrientationId ];
		}

		var thisOrientationId = ( frameOrientationId == "VER" ? "VER" : "HOR" );
		if ( Len( arguments.orientationId ) && ArrayFind( orientationIds, arguments.orientationId ) ) {
			thisOrientationId = arguments.orientationId;
		}

		var blocks = [];
		var slotCounter = 0;
		var flowCursor  = 0; // bordo finale (destro o inferiore) del blocco precedente
		var plateWidth  = 0;
		var plateHeight = 0;

		var frameBlocks = arguments.frame.getBlocks();

		if ( IsNull( frameBlocks ) ) {
			frameBlocks = [];
		}

		for ( var block in frameBlocks ) {

			var mode = block.getOrientationMode();
			var effectiveOri = ( mode == "HAV" ? thisOrientationId : mode );

			// override per singolo blocco (rotazione dal preventivo)
			var orderKey = ToString( block.getOrder() );
			if ( StructKeyExists( overrides, orderKey ) && ListFindNoCase( "HOR,VER", overrides[ orderKey ] ) ) {
				effectiveOri = UCase( overrides[ orderKey ] );
			}

			var blockWidth  = 0;
			var blockHeight = 0;

			if ( effectiveOri == "HOR" ) {
				blockWidth  = block.getSlotCount() * variables.SLOT_WIDTH_MM;
				blockHeight = variables.SLOT_HEIGHT_MM;
			} else {
				blockWidth  = variables.SLOT_HEIGHT_MM;
				blockHeight = block.getSlotCount() * variables.SLOT_WIDTH_MM;
			}

			var blockLeft = 0;
			var blockTop  = 0;

			if ( thisOrientationId == "HOR" ) {
				blockLeft  = flowCursor + block.getMarginLeftMm();
				blockTop   = block.getMarginTopMm();
				flowCursor = blockLeft + blockWidth;
			} else {
				blockTop   = flowCursor + block.getMarginTopMm();
				blockLeft  = block.getMarginLeftMm();
				flowCursor = blockTop + blockHeight;
			}

			var slots = [];
			for ( var i = 1; i <= block.getSlotCount(); i++ ) {
				slotCounter++;
				slots.add( {
					"id"    = slotCounter,
					"order" = slotCounter - 1,
					"type"  = "_"
				} );
			}

			blocks.add( {
				"id"              = block.getId(),
				"order"           = block.getOrder(),
				"orientationMode" = mode,
				"rotatable"       = block.getRotatable(),
				"slotCount"       = block.getSlotCount(),
				"marginTopMm"     = block.getMarginTopMm(),
				"marginLeftMm"    = block.getMarginLeftMm(),
				"left"            = blockLeft,
				"top"             = blockTop,
				"width"           = blockWidth,
				"height"          = blockHeight,
				"cellOrientation" = effectiveOri,
				"slots"           = slots
			} );

			plateWidth  = Max( plateWidth, blockLeft + blockWidth );
			plateHeight = Max( plateHeight, blockTop + blockHeight );
		}

		if ( ArrayLen( blocks ) ) {
			plateWidth  = plateWidth  + arguments.frame.getMarginRightMm();
			plateHeight = plateHeight + arguments.frame.getMarginBottomMm();
		}

		return {
			"orientationId"  = thisOrientationId,
			"orientationIds" = orientationIds,
			"blocks"         = blocks,
			"width"          = plateWidth,
			"height"         = plateHeight,
			"slotSize"       = {
				"width"  = variables.SLOT_WIDTH_MM,
				"height" = variables.SLOT_HEIGHT_MM
			}
		};
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

		if( ( !IsNull( arguments.frame.getBlocks() ) ) ) {

			for( var block in arguments.frame.getBlocks() ) {
				block.setFrameId( newId );
				getFrameBlockService().create( block );
			}

		}

		// Auto-crea il modello corrispondente (type S, categoria Placche 22) se non esiste già
		if ( !getModelService().codeExists( arguments.frame.getCode() ) ) {
			try {
				var totalSlots = 0;
				if ( !IsNull( arguments.frame.getBlocks() ) ) {
					for ( var b in arguments.frame.getBlocks() ) {
						totalSlots += b.getSlotCount();
					}
				}

				var model         = super.bean( "Model" );
				var modelType     = super.bean( "ModelType" );
				var modelStatus   = super.bean( "Status" );
				var modelCategory = super.bean( "ProductCategory" );

				var nameText = super.bean( "Text" );
				nameText.setId( "" );
				nameText.setName( arguments.frame.getCode() );
				nameText.setLang( super.bean( "Lang" ).setId( "IT" ) );
				nameText.setStatus( super.bean( "Status" ).setId( "TRA" ) );
				nameText.setKind( super.bean( "TextKind" ).setId( "NAME" ) );

				modelCategory.setId( 22 );
				model.setCode( arguments.frame.getCode() );
				model.setType( modelType.setId( "S" ) );
				model.setStatus( modelStatus.setId( "ACT" ) );
				model.setCategories( [ modelCategory ] );
				model.setFruitsCount( totalSlots );
				model.setTexts( [ nameText ] );

				getModelService().create( model );
			} catch ( any e ) {
				// la creazione del modello è non bloccante: il frame è già salvato
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

			getFrameBlockService().deleteByFrameId( arguments.frame.getId() );

			if( ( !IsNull( arguments.frame.getBlocks() ) ) ) {

				for( var block in arguments.frame.getBlocks() ) {
					block.setFrameId( frame.getId() );
					getFrameBlockService().create( block );
				}

			}

		}

		return arguments.frame.getId();
	}

	public Any function getByCode( required String code ){
		var record = getDao().readByCode( arguments.code );

		if ( record.recordCount ) {
			return get( record.frame_id );
		}

		return NullValue();
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

		// Precarica i FrameBlock in batch
		var blockMap = {};
		if ( ArrayLen( frameIds ) ) {
			var blockRecords = getFrameBlockService().getDao().readByFrameIds( frameIds = frameIds );
			for ( var br in blockRecords ) {
				var frameId = br.frame_id;
				if ( !StructKeyExists( blockMap, frameId ) ) {
					blockMap[ frameId ] = [];
				}
				var blockBean = super.bean( "FrameBlock" );
				blockBean.setId( br.frame_block_id );
				blockBean.setOrder( br.order );
				blockBean.setSlotCount( br.slot_count );
				blockBean.setMarginTopMm( br.margin_top_mm );
				blockBean.setMarginLeftMm( br.margin_left_mm );
				blockBean.setOrientationMode( br.orientation_mode );
				blockBean.setRotatable( br.rotatable );
				blockBean.setFrameId( br.frame_id );
				blockBean.setCreatedAt( br.created_at );
				ArrayAppend( blockMap[ frameId ], blockBean );
			}
		}

		for ( var record in records ) {
			var bean = super.bean( "Frame" );

			// Campi diretti dal record
			bean.setId( record.frame_id );
			bean.setName( record.frame );
			bean.setCode( record.code );
			bean.setCreatedAt( record.created_at );
			if ( !IsNull( record.margin_right_mm ) )  bean.setMarginRightMm( record.margin_right_mm );
			if ( !IsNull( record.margin_bottom_mm ) ) bean.setMarginBottomMm( record.margin_bottom_mm );

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

			// FrameBlock: dalla mappa pre-caricata
			if ( StructKeyExists( blockMap, record.frame_id ) && ArrayLen( blockMap[ record.frame_id ] ) ) {
				bean.setBlocks( blockMap[ record.frame_id ] );
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
		if ( !IsNull( record.margin_right_mm ) )  bean.setMarginRightMm( record.margin_right_mm );
		if ( !IsNull( record.margin_bottom_mm ) ) bean.setMarginBottomMm( record.margin_bottom_mm );

		// Entity collegate (caricate singolarmente)
		bean.setOrientation( getLookupService().get( "orientation", record.orientation_id ) );
		bean.setCellOrientation( getLookupService().get( "orientation", record.cell_orientation_id ) );
		bean.setStatus( getStatusService().get( record.status_id ) );

		bean.setCells( getFrameCellService().list( record.frame_id ) );
		bean.setBlocks( getFrameBlockService().list( frameId = record.frame_id ) );

		return bean;
	}

}
