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
		var result  = super.getResult();

		if ( !super.isUuid( rc.id ) ) {
			return event.setValue( "result", "No UUID" );
		}

		var bean = super.fire( "frame.get", [ rc.id ] );

		var obj = super.getMementify().convert( bean, "detail" );

		result.setData( obj );

		event.setValue( "result", result );
	}

	function codeExists( event, rc, prc ){
		param rc.id   = "_";
		param rc.code = "";

		var result = super.fire( "frame.codeExists", { code = rc.code, excludedId = rc.id } );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		
		var json = DeserializeJSON( GetHTTPRequestData().content );

		var cells = [];

		var thisId     = "";
		var messageId  = "";
		var result = super.getResult();

		var frame  = super.bean( "Frame" );
		var status = super.bean( "Status" );
		var orientation = super.bean( "Orientation" );
		var cellOrientation = super.bean( "Orientation" );

		//dump(json.cells);

		for ( var col in json.cells ) {

            for ( var thisCell in col.cells ) {

                if ( thisCell.data.type.id != "COMMAND" ) {

					var cell = super.bean( "FrameCell" );
					var type = super.bean( "FrameCellType" );
					var orientation = super.bean( "Orientation" );

					cell.setRow( thisCell.data.row )
					cell.setCol( thisCell.data.col )
					cell.setWidth( thisCell.data.width )
					cell.setHeight( thisCell.data.height )
					
					cell.setType( type.setId( thisCell.data.type.id ) )
					cell.setOrientation( orientation.setId( thisCell.data.orientation.id ) )

					cells.add( cell )

                }

            }

        }

		frame.setCells( cells );

		frame.setId( json?.id );
		frame.setCode( json.code );
		frame.setName( json.name );
		frame.setStatus( status.setId( json.status.id ) );
		frame.setOrientation( orientation.setId( json.Orientation.id ) );
		frame.setCellOrientation( cellOrientation.setId( json.cellOrientation.id ) );
		
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
