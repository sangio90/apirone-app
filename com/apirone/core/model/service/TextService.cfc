component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.TextDAO";
	property name="langService" type="com.apirone.core.model.service.LangService";

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
    
    public com.apirone.core.model.bean.Result function list(
		String statusId,
	) {
		arguments['limit'] = -1;
		return search(argumentCollection = arguments).getData()
	}

    private com.apirone.core.model.bean.Result function search(
                     String statusId,
                     String attributeId,
                     Numeric attributeValueId,
            required Numeric limit = 20,
			required Numeric offset = 0,
    	){

	    var rows = [];
    	var result = super.getResult();

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

		var newId = return getDao().update( arguments.text );

		return text.getId();

	}

	public String function update(
			required com.apirone.core.model.bean.Attribute attribute
		){
		
            var id = getDao().update( arguments.option ).toString();
            
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
			bean.setLang( getLangService().getId( record.lang_id ) );
			
			return bean;
			
		}

		return NullValue();

	}
	  
  	private String function getCacheKey( required Numeric id ) {

  		return "Text_#arguments.id#";

  	}

}
