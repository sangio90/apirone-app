component extends="com.apirone.core.controller.AbsController" {

	// Dimensioni fisiche di uno slot (mezzofrutto). Scala di disegno: 1mm = 1px.
	variables.SLOT_WIDTH_MM  = 45;
	variables.SLOT_HEIGHT_MM = 180;

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();

		var params = super.paramsFromUrl();

		var rows = super.fire( "frame.search", params );

		var data = getMementify().convertList( rows.getData() );

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		param rc.id = "___";
		param rc.orientationId = "";
		param rc.productId = "";
		param rc.blockOrientations = "";

		var result = super.getResult();

		var bean = super.fire( "frame.get", [ rc.id ] );

		var obj = "";

		if ( !IsNull( bean.getBlocks() ) && ArrayLen( bean.getBlocks() ) ) {
			obj = buildBlocksResponse( bean, rc.orientationId, rc.blockOrientations );
		} else {
			// fallback transitorio: placche non ancora migrate, lette dal file JSON
			obj = buildLegacyFileResponse( bean, rc.orientationId );
		}

		obj["image"] = "";

		if ( Len( rc.productId ) ) {
			var product = super.fire( "product.get", [ rc.productId ] );
			var image = product.getImage( typeId = (obj.orientation.getId() == 'HOR' ? 'horizontal' : 'vertical') );
			if ( Len( image ) ) {
				obj["image"] = super.getMementify().convert( image );
			}
		}

		// le lookup orientation vengono serializzate alla fine
		obj["orientation"]     = super.getMementify().convert( obj.orientation );
		obj["cellOrientation"] = super.getMementify().convert( obj.cellOrientation );

		var availableOrientations = [];
		for ( var ori in obj.availableOrientations ) {
			availableOrientations.add( super.getMementify().convert( ori ) );
		}
		obj["availableOrientations"] = availableOrientations;

		result.setData( obj );

		event.setValue( "result", result );
	}

	/**
	 * Costruisce la risposta per le placche a blocchi (configurazione su DB).
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
	 */
	private Struct function buildBlocksResponse( required Any bean, String orientationId = "", String blockOrientations = "" ){

		var overrides = {};
		if ( Len( arguments.blockOrientations ) && IsJSON( arguments.blockOrientations ) ) {
			overrides = DeserializeJSON( arguments.blockOrientations );
		}

		var frameOrientationId = bean.getOrientation().getId();

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

		for ( var block in bean.getBlocks() ) {

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

		var availableOrientations = [];
		for ( var thisOri in orientationIds ) {
			availableOrientations.add( super.service( "Lookup" ).get( "orientation", thisOri ) );
		}

		var obj = super.getMementify().convert( bean, "detail" );

		obj.remove( "cells" );
		obj.remove( "grid" );

		obj["orientation"]     = super.service( "Lookup" ).get( "orientation", thisOrientationId );
		obj["cellOrientation"] = super.service( "Lookup" ).get( "orientation", thisOrientationId );
		obj["availableOrientations"] = availableOrientations;

		obj["blocks"] = blocks;
		obj["width"]  = plateWidth;
		obj["height"] = plateHeight;

		obj["slotSize"] = {
			"width"  = variables.SLOT_WIDTH_MM,
			"height" = variables.SLOT_HEIGHT_MM
		};

		return obj;
	}

	/**
	 * Risposta legacy basata sui file /config/data/plates/grid_<code>.json.cfm.
	 * Mantenuta come fallback finche' tutte le placche non sono migrate a blocchi.
	 */
	private Struct function buildLegacyFileResponse( required Any bean, String orientationId = "" ){

		var code   = bean.getCode();
		var config = DeserializeJSON( FileRead( ExpandPath( "/config/data/plates/grid_#code#.json.cfm" ) ) );

		var thisOrientationId = "";

		if ( Len( arguments.orientationId ) && StructKeyExists( config.frame.orientations, arguments.orientationId ) ) {
			thisOrientationId = arguments.orientationId;
		} else {
			// se non lo passo, il primo disponibile
			thisOrientationId = ListFirst( StructKeyList( config.frame.orientations ) );
		}

		var orientationConfig = config.frame.orientations[ thisOrientationId ];
		var orientationIds = StructKeyList( config.frame.orientations );

		var availableOrientations = [];
		for ( var thisOri in orientationIds ) {
			availableOrientations.add( super.service( "Lookup" ).get( "orientation", thisOri ) );
		}

		var obj = super.getMementify().convert( bean, "detail" );

		obj.remove( "cells" );
		obj.remove( "blocks" );

		obj["orientation"]     = super.service( "Lookup" ).get( "orientation", thisOrientationId );
		obj["cellOrientation"] = super.service( "Lookup" ).get( "orientation", orientationConfig.cellOrientation );
		obj["availableOrientations"] = availableOrientations;

		obj["grid"] = orientationConfig["grid"];

		return obj;
	}

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "frame.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){

		var json = DeserializeJSON( GetHTTPRequestData().content );

		var thisId     = "";
		var messageId  = "";
		var result = super.getResult();

		var frame  = super.bean( "Frame" );
		var status = super.bean( "Status" );
		var orientation = super.bean( "Orientation" );
		var cellOrientation = super.bean( "Orientation" );

		// payload builder: blocchi di slot
		if ( !IsNull( json.blocks ) ) {

			var blocks = [];

			for ( var thisBlock in json.blocks ) {

				var block = super.bean( "FrameBlock" );

				block.setOrder( thisBlock.order );
				block.setSlotCount( thisBlock.slotCount );

				if ( !IsNull( thisBlock.marginTopMm ) && IsNumeric( thisBlock.marginTopMm ) ) block.setMarginTopMm( thisBlock.marginTopMm );
				if ( !IsNull( thisBlock.marginLeftMm ) && IsNumeric( thisBlock.marginLeftMm ) ) block.setMarginLeftMm( thisBlock.marginLeftMm );

				block.setOrientationMode( thisBlock.orientationMode );
				if ( !IsNull( thisBlock.rotatable ) ) block.setRotatable( thisBlock.rotatable );

				blocks.add( block );
			}

			frame.setBlocks( blocks );
		}

		// payload legacy (vecchia pagina armature a celle)
		if ( !IsNull( json.cells ) ) {

			var cells = [];

			for ( var col in json.cells ) {

				for ( var thisCell in col.cells ) {

					if ( thisCell.data.type.id != "COMMAND" ) {

						var cell = super.bean( "FrameCell" );
						var type = super.bean( "FrameCellType" );
						var orientationCell = super.bean( "Orientation" );

						cell.setRow( thisCell.data.row )
						cell.setCol( thisCell.data.col )
						cell.setWidth( thisCell.data.width )
						cell.setHeight( thisCell.data.height )

						cell.setType( type.setId( thisCell.data.type.id ) )
						cell.setOrientation( orientationCell.setId( thisCell.data.orientation.id ) )

						cells.add( cell )

					}

				}

			}

			frame.setCells( cells );
		}

		frame.setId( json?.id );
		frame.setCode( json.code );
		frame.setName( json.name );
		frame.setStatus( status.setId( json.status.id ) );
		frame.setOrientation( orientation.setId( json.Orientation.id ) );

		// cell_orientation_id: legacy, per il payload builder coincide con l'orientamento
		if ( !IsNull( json.cellOrientation ) ) {
			frame.setCellOrientation( cellOrientation.setId( json.cellOrientation.id ) );
		} else {
			frame.setCellOrientation( cellOrientation.setId( json.Orientation.id == "HAV" ? "HOR" : json.Orientation.id ) );
		}

		if ( !Len( json.id ) ) {
			messageId = "frame.created";
			thisId    = super.fire( "frame.create", [ frame ] )
		} else {
			messageId = "frame.updated";
			thisId    = super.fire( "frame.update", [ frame ] )
		}

		var message = completeMessage( messageId );

		result.setData( { "message" = message }, { "payload" = { "id" = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result    = super.getResult();
		var list      = GetHTTPRequestData().content;
		var messageId = "frame.deletedAllRecords";

		var errors  = [];
		var payload = "";

		var ids = ListToArray( list );

		for ( var id in ids ) {
			var outcome = super.fire( "frame.delete", [ id ] );

			if ( outcome.getStatus() == "ERROR" ) {
				errors.add( { "message" = "Non sono riuscito a cancellare l'Id #id#" } )
			}
		}

		if ( errors.len() ) {
			messageId = "frame.deletedNotAllRecords"
			payload   = { "errors" = errors };
		}

		var message = super.completeMessage( messageId );

		result.setData( { "message" = message, "payload" = payload } );

		event.setValue( "result", result );
	}

}
