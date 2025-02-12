component extends="com.apirone.core.model.service.AbsService" accessors="true" {

    property name="textService" type="com.apirone.core.model.service.TextService";
    property name="statusService" type="com.apirone.core.model.service.StatusService";
    property name="langService" type="com.apirone.core.model.service.LangService";

    public com.apirone.core.model.bean.FileType function get(
    		required String fileTypeId
        ){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.fileTypeId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var bean = build( arguments.fileTypeId );
		
		cm.put( key, bean );
        
		return bean;

	}

    /*
    	private method
	*/

	private com.apirone.core.model.bean.FileType function build(
    		required String fileTypeId
    	){

		var records = DESerializeJSON( FileRead( "/config/data/fileTypes.json.cfm" ) );

		for( var record in records ) {

			if( record.id == arguments.fileTypeId ) {

				var bean = super.bean("FileType");
				
				bean.setId( record.id );

				bean.setStatus( getStatusService().get( "ACT" ) );
				bean.setTexts( createTexts( record ) );
				
				return bean;
	
			}

		}

		return nullValue();

  	}

  	private com.apirone.core.model.bean.Text[] function createTexts( required Struct record ) {

		var langs = getLangService().list();

		var texts = [];


		for( var thisLang in langs ) {
			
			var name = "** To translate";
			var id = "NOT_SET";

			for( var thisText in arguments.record.texts ) {

				if( thisLang.getId() == thisText.lang.id ) {

					id = arguments.record.id;
					name = thisText.name;

				}

				var text   = super.bean("Text");
				var lang   = super.bean("Lang");
				var status = super.bean("Status");
				
				status.setId( "ACT" );
				
				lang.setId( thisLang.getId() );
	
				text.setId( -1 );
				text.setName( name );
				
				text.setId( id );
				text.setStatus( status );
				text.setLang( lang );
	
			}

			texts.add( text );

		}
		
  		return texts;

  	}

  	private String function getCacheKey( required String id ) {

  		return "FileType_#arguments.id#";

  	}

}
