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

	private com.apirone.core.model.bean.FileType function build( required String fileTypeId ){
		var records = DeserializeJSON( FileRead( "/config/data/fileTypes.json.cfm" ) );

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
		var langs = getLangService().list();

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
