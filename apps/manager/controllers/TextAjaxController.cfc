/*
	TODO: 
		
		-1
		use status not ""** To translate" (e il select relativo)
		
		un traduttore potrebbe evitare di mettere online 
		la traduzione anche se l'ha scritta ma non l'ha approvata

		-2
		aggiungere il kind nella modale (es: nome, descrizione)

		-3
		cache delle text
		(adesso c'è un brutto reload sul client al salvataggio)
		window.location.href = window.location.pathname+"?"+$.param( { "reset":1, "fwreinit":1 } );

		-4 
		miglioare ui per la finestra di modifica

		-5
		nella lista mostra getEntityName() lasciando i riferimenti dell'entity

*/

component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var memy = super.getMementify();

		var params = paramsFromUrl();

		var rows = super.fire( "text.search", params );

		for ( var row in rows.getData() ) {

			var statuses = [];

			var langs = super.fire( "text.list", { entity = row.getEntity(), kind = row.getKind().getId() } );

			for( var lang in langs ) {

					var status = {
						"id"  = "TRA",
						"hex" = "##32CD32"
					}

				if( lang.getName() == "** To translate" ) {
					var status = {
						"id"  = "TOT",
						"hex" = "##B2BEB5"
					}
				};

				statuses.add( {
					"text"   = lang.getName(),
					"lang"   = lang.getLang(),
					"status" = status
				} );

			}

			var obj = memy.convert( row, "list" );
			obj["statuses"] = statuses;

			data.add( obj );
		}

		result.setTotal( rows.getTotal() );
		result.setCount( rows.getCount() );

		result.setData( data );

		event.setValue( "result", result );
	}

	// all texts by entity
	function all( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var dm     = getDataMapper();

		var text = super.fire( "text.get", [ rc.id ] );

		var rows = super.fire( "text.list", { entity = text.getEntity(), kind = text.getKind().getId() } );

		for ( var row in rows ) {
			var bean = dm.convert( row, "Text", true );

			data.add( bean );
		}

		result.setData( data );

		event.setValue( "result", result );
	}

	function get( event, rc, prc ){
		var data   = [];
		var result = super.getResult();
		var dm     = getDataMapper();

		var obj = super.fire( "text.get", [ rc.id ] );

		var bean = dm.convert( obj, "Text", true );

		result.setData( bean );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){

		var result = super.getResult();
		var thisId    = "";
		var messageId = "text.saved";

		var json = DeserializeJSON( GetHTTPRequestData().content );

		for( var row in json ) {

			var text   = super.bean( "Text" );
			var lang   = super.bean( "Lang" );
			var status = super.bean( "Status" );

			text.setId( row.id )
			text.setName( row.name )
			text.setLang( lang.setId( row.lang.id ) );
			text.setStatus( status.setId( row.status.id ) );

			thisId = super.fire( "text.update", [ text ] )

		} 

		var message = completeMessage( messageId );

		result.setData( message, { payload = { id = thisId } } );

		event.setValue( "result", result );
	}

	function createTraduzioniMancanti( event, rc, prc ){

		var result = super.getResult();
		var thisId    = "";
		var messageId = "text.saved";

		var id = rc.id

		var createdCounter = createTraduzioniByTextId(id)

		var message = completeMessage( messageId );

		result.setCount( createdCounter )
		result.setData( message );

		event.setValue( "result", result );
	}

	function createAllTraduzioniMancanti( event, rc, prc ){

		var result = super.getResult();
		var thisId    = "";
		var messageId = "text.saved";

		var rows = super.fire( "text.list" );

		var createdCounter = 0;
		transaction {
			for ( var row in rows ) {

				var statuses = [];

				var hasItalian = super.fire( "text.list", { entity = row.getEntity(), kind = row.getKind().getId(), langId = 'IT' } );

				if (Len(hasItalian) > 0) {
					var italianText = hasItalian[1];
					var id = italianText.getId();
					var thisCreatedCounter = createTraduzioniByTextId(id)
					createdCounter += thisCreatedCounter;
				}			
			}
		}

		var message = completeMessage( messageId );

		result.setCount( createdCounter )
		result.setData( message );

		event.setValue( "result", result );
	}

	public function createTraduzioniByTextId(id)
	{
		var text = super.fire( "text.get", [ id ] );

		if (isNull(text)) {
			result.setStatus( "ERROR" );
			return result;
		}

		var textEntity = text.getEntity();
		var textKind = text.getKind();
		var allEntityTexts = super.fire( "text.list", { entity = textEntity, kind = textKind.getId() }  );
		var requiredLangs = ["IT","EN","FR","ES","DE"];

		var presentLangs = allEntityTexts.map(function(text){
			return text.getLang().getId();
		});

		var missingLangs = requiredLangs.filter(function(lang){
			return !presentLangs.contains(lang);
		});
		
		var createdCount = 0
		for ( var missingLang in missingLangs ) {

			var newText   = super.bean( "Text" );
			var lang   = super.bean( "Lang" );
			var status = super.bean( "Status" );

			newText.setEntity( textEntity );
			newText.setKind( textKind );
			newText.setName( "** To translate" )
			newText.setLang( lang.setId( missingLang ) );
			newText.setStatus( status.setId( "TOT" ) );

			thisId = super.fire( "text.create", [ newText ] );
			createdCount++
		}

		return createdCount;
	}

	private function getEntityName( id ){
		// TODO: consider to move into DBFields.json

		var result = "";

		switch ( arguments.id ) {
			case "attribute.id":
				WriteOutput( "I like apples!" );
				result = "Attributo";
				break;
			case "attributeValue.id":
				result = "Valore attributo";
				break;
			case "productCategory.id":
				result = "Categoria prodotto";
				break;
			case "finish.id":
				result = "Finitura";
				break;
			case "model.id":
				result = "Dimensione";
				break;
			case "product.id":
				result = "Prodotto";
				break;
			case "rawValue.id":
				result = "Valore base";
				break;
			default:
				result = "** Entity not found";
				break;
		}

		return result;
	}

}
