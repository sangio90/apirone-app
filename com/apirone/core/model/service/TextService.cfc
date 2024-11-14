component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.TextDAO";
	property name="langService" type="com.apirone.core.model.service.LangService";
	property name="statusService" type="com.apirone.core.model.service.StatusService";

	public com.apirone.core.model.bean.Text function get(
			required String textId
    	){

			var cm = getCacheManager();

			var key = getCacheKey( arguments.textId );
	
			   var cache = cm.get( key ) ;
	
			if ( cache.status ) {
			
				  return cache.data;
			
			}
			
			var bean = build( arguments.textId );
			
            cm.put( key, bean );
			
            return bean;

	} 
    
    public com.apirone.core.model.bean.Text[] function list(
		String statusId,
	) {
		arguments["limit"] = -1;
		return search(argumentCollection = arguments).getData()
	}

    public com.apirone.core.model.bean.Result function search(
                     String statusId,
                     String attributeId,
                     Numeric attributeValueId,
                     Numeric lineCategoryId,
                     String langId,
            required Numeric limit = 20,
			required Numeric offset = 0,
			required Array orderBy = [ { field='lang.orderBy', sort="asc" } ]
    	){

	    var rows = [];
    	var result = super.getResult();

		arguments["orderby"] = super.createOrderBy( arguments["orderby"] );

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( textId = record.text_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }

	public String function create(
			required com.apirone.core.model.bean.Text text
		){

		var newId = getDao().insert( arguments.text );

		return newId;

	}


	public Array function bulkCreate(
			required com.apirone.core.model.bean.Text[] texts
		){

		var langs = getLangService().list( statusId="ACT" );

		var ids = [];
		var langDone = [];

		// one at least
		var entity = arguments.texts[1].getEntity();

		for( var thisText in arguments.texts ) {

			var newId = getDao().insert( thisText );
			langDone.add( thisText.getLang().getId() );

			ids.add( newId );

		}

		for ( var thisLang in langs ) {

			if( !ArrayFind( langDone, thisLang.getId() ) ) {

				var text = super.bean("Text");
				var lang = super.bean("Lang");
				var status = super.bean("Status");

				text.setName("** To translate");

				lang.setId( thisLang.getId() );
				status.setId( "TOT" );

				text.setStatus( status );
				text.setLang( lang );
				text.setEntity( entity );

				var newId = getDao().insert( text );

				ids.add( newId );

			}

		}

		return ids;

	}

	public String function update(
			required com.apirone.core.model.bean.Text text
		){
		
        var id = getDao().update( arguments.text );
            
		getCacheManager().remove( getCachekey( id ) );
			
		return id;
    
	}
    
    /**
     * @private
     */
    private com.apirone.core.model.bean.Text function build(
		required String textId
	){

		var record = getDao().read( textId = arguments.textId );

		if( record.RecordCount ) { 
			
			var bean = super.bean( "Text" );

			bean.setId( record.text_id );
			bean.setName( record.text );
			bean.setLang( getLangService().get( record.lang_id ) );
			bean.setStatus( getStatusService().get( record.status_id ) );
			bean.setEntity( getEntity( record ) );

			getStatusService().get( record.status_id )
			
			return bean;
			
		}

		return NullValue();

	}
	  
  	private String function getCacheKey( required Numeric id ) {

  		return "Text_#arguments.id#";

  	}

  	private com.apirone.core.model.bean.Entity function getEntity( required record ) {

		var entity = super.bean( "Entity" );

		if( Len( record.attribute_id ) ) {

			entity.setKey( "attribute.id" );
			entity.setValue( record.attribute_id );

			return entity;

		}

		if( Len( record.attribute_value_id ) ) {

			entity.setKey( "attributeValue.id" );
			entity.setValue( record.attribute_value_id );

			return entity;
			
		}
		
		return NullValue()

  	}

}
