component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var mm     = super.getMementify();

		var params = super.paramsFromUrl();

		var rows = super.fire( "LineModelCost.search", params );

		for ( var row in rows.getData() ) {
			data.append( mm.convert( row ) );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );
		result.setData( data );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
		var json = DeserializeJSON( event.getHTTPContent() );

		var thisId  = "";
		var message = "";
		var result  = super.getResult();

		var lineModelCost = super.bean( "LineModelCost" );
		lineModelCost.setCost( json.cost );
		lineModelCost.setCategory( super.fire( "ProductCategory.get", [ json.categoryId ] ) );
		lineModelCost.setLine( super.fire( "Line.get", [ json.lineId ] ) );
		lineModelCost.setModel( super.fire( "Model.get", [ json.modelId ] ) );

		try {
			if ( IsNull( json.id ) || !Len( json.id ) ) {
				thisId = super.fire( "LineModelCost.create", [ lineModelCost ] );
				message = "Costo linea/modello creato.";
			} else {
				lineModelCost.setId( json.id );
				thisId = super.fire( "LineModelCost.update", [ lineModelCost ] );
				message = "Costo linea/modello aggiornato.";
			}
		} catch ( any e ) {
			writeLog( type = "Error", file = "application", text = "LineModelCost.save: #e.message# #e.detail ?: ''#" );
			result.setStatus( "ERROR" );
			// violazione dell'indice univoco (line_id, model_id)
			message = FindNoCase( "line_model_costs_line_model_idx", e.message & ( e.detail ?: "" ) )
				? "Esiste già un costo per questa linea/modello."
				: "Errore nella procedura.";
		}

		result.setData( { "message" = message, "payload" = { "id" = thisId } } );

		event.setValue( "result", result );
	}

	function delete( event, rc, prc ){
		var result  = super.getResult();
		var json    = DeserializeJSON( event.getHTTPContent() );
		var message = "Costo linea/modello cancellato.";

		var outcome = super.fire( "LineModelCost.delete", [ json.id ] );

		if ( outcome.getStatus() == "ERROR" ) {
			result.setStatus( "ERROR" );
			message = "Non sono riuscito a cancellare l'Id #json.id#";
		}

		result.setData( { "message" = message } );

		event.setValue( "result", result );
	}

}
