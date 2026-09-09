component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="textService" inject="TextService";
	property name="statusService" inject="StatusService";
	property name="langService" inject="LangService";

	public com.apirone.core.model.bean.FileType function get( required String fileTypeId ){
		return build( arguments.fileTypeId );
	}

	/*
    	private method
	*/

	/*
		Costruisce un FileType a partire dal file di configurazione statico.
		Il JSON parsato e l'elenco lingue sono memoizzati nel request scope: evita
		di rileggere il file ed eseguire una query langs per ogni bean FileType
		costruito (~110 volte durante il salvataggio di una placca).
	*/
	private com.apirone.core.model.bean.FileType function build( required String fileTypeId ){
		// Config statica: il parsing del JSON avviene una sola volta per request
		if ( !StructKeyExists( request, "_fileTypesConfig" ) ) {
			request._fileTypesConfig = DeserializeJSON( FileRead( "/config/data/fileTypes.json.cfm" ) );
		}
		var records = request._fileTypesConfig;

		for ( var record in records ) {
			if ( record.id == arguments.fileTypeId ) {
				var bean = super.bean( "FileType" );

				bean.setId( record.id );

				bean.setStatus( getStatusService().get( "ACT" ) );
				bean.setTexts( createTexts( record ) );

				return bean;
			}
		}

		return NullValue();
	}

	public array function createTexts( required struct record ){
		// Elenco lingue statico: memoizzato nel request scope per
		// evitare una query langs per ogni FileType
		if ( !StructKeyExists( request, "_fileTypeLangs" ) ) {
			request._fileTypeLangs = getLangService().list();
		}
		var langs = request._fileTypeLangs;

		var texts = [];


		for ( var thisLang in langs ) {
			var name = "** To translate";
			var id   = "NOT_SET";

			for ( var thisText in arguments.record.texts ) {
				if ( thisLang.getId() == thisText.lang.id ) {
					id   = arguments.record.id;
					name = thisText.name;
				}

				var text   = super.bean( "Text" );
				var lang   = super.bean( "Lang" );
				var status = super.bean( "Status" ).setId( "ACT" );
				var kind   = super.bean( "TextKind" ).setId( "NAME" );

				lang.setId( thisLang.getId() );

				text.setId( -1 );
				text.setName( name );

				text.setId( id );
				text.setStatus( status );
				text.setLang( lang );
				text.setKind( kind );
			}

			texts.add( text );
		}

		return texts;
	}

}
