component extends="com.apirone.core.controller.AbsController" {

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

		var jsonFilePath = ExpandPath( "/config/data/plates/grid_#bean.getCode()#.json.cfm" );

		if ( !IsNull( bean.getBlocks() ) && ArrayLen( bean.getBlocks() ) ) {
			obj = buildBlocksResponse( bean, rc.orientationId, rc.blockOrientations );
		} else if ( FileExists( jsonFilePath ) ) {
			obj = buildLegacyFileResponse( bean, rc.orientationId );
		} else {
			Throw( message = "Nessuna configurazione trovata per la placca #bean.getCode()#" );
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

		// Il calcolo sta in FrameService.layout(): lo usa anche la stampa, che
		// dall'ingombro ricava dove sta la placca dentro all'anteprima salvata.
		var layout = super.service( "Frame" ).layout(
			frame             = arguments.bean,
			orientationId     = arguments.orientationId,
			blockOrientations = arguments.blockOrientations
		);

		var availableOrientations = [];
		for ( var thisOri in layout.orientationIds ) {
			availableOrientations.add( super.service( "Lookup" ).get( "orientation", thisOri ) );
		}

		var obj = super.getMementify().convert( arguments.bean, "detail" );

		obj.remove( "cells" );
		obj.remove( "grid" );

		obj["orientation"]     = super.service( "Lookup" ).get( "orientation", layout.orientationId );
		obj["cellOrientation"] = super.service( "Lookup" ).get( "orientation", layout.orientationId );
		obj["availableOrientations"] = availableOrientations;

		obj["blocks"]         = layout.blocks;
		obj["marginRightMm"]  = arguments.bean.getMarginRightMm();
		obj["marginBottomMm"] = arguments.bean.getMarginBottomMm();
		obj["width"]          = layout.width;
		obj["height"]         = layout.height;

		obj["slotSize"] = layout.slotSize;

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
		if ( !IsNull( json.marginRightMm )  && IsNumeric( json.marginRightMm ) )  frame.setMarginRightMm( json.marginRightMm );
		if ( !IsNull( json.marginBottomMm ) && IsNumeric( json.marginBottomMm ) ) frame.setMarginBottomMm( json.marginBottomMm );
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
