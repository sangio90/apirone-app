component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	property name="dao" type="com.apirone.core.model.dao.FileDAO";
	property name="fileTypeService" type="com.apirone.core.model.service.FileTypeService";
	property name="MediaService" type="com.apirone.core.model.service.MediaService";

    public com.apirone.core.model.bean.File function get(
    		required String fileId
        ){

    	var cm = super.getCacheManager();

    	var key = getCacheKey( arguments.fileId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      	return cache.data;
	    
	    } 
	    
		var obj = build( arguments.fileId );
		cm.put( key, obj );
        
		return obj;

	}

	public String function create(
		required com.apirone.core.model.bean.File file,
		required com.apirone.core.model.bean.Entity entity
	){		

		return getDao().insert( 
			argumentCollection = arguments
		).toString()

	}

	
	public Void function delete(
		required String fileId
	){		

	
		return getDao().delete( 
			argumentCollection = arguments
		)

	}

	public com.apirone.core.model.bean.File[] function list() {
		arguments["limit"] = -1;
		
		return search( argumentCollection = arguments).getData();
	
	}

	public com.apirone.core.model.bean.Result function search(
				 String str,
				 String productVariantId,
		required Numeric limit = 50,
		required Numeric offset = 0,
    ){

		var rows = [];

        var result = super.getResult()

    	var records = getDao().find( argumentCollection=arguments );

	    for( var record in records ){

	    	rows.add( 
	    		get( fileId = record.file_id )
	    	);

	    }

		result.setTotal( records.total );
		result.setCount( records.RecordCount() );
		result.setData( rows );

        return result;

	}

    public com.apirone.core.model.bean.Result function list(
					 String str,
					 String productVariantId
		){

		arguments["limit"] = -1;

		return search( argumentCollection = arguments );

	}

    /*
    	private method
	*/

	private com.apirone.core.model.bean.File function build(
    		required String fileId
    	){

	    var record = getDao().read( arguments.fileId );

	    if( record.RecordCount ) { 

          	var obj = super.bean( "File" );

            obj.setId( record.file_id.toString() );
            obj.setSize( record.size );
            obj.setWidth( record.width );
            obj.setHeight( record.height );
			obj.setName( record.name );
            obj.setExtension( record.extension );
            obj.setDescription( record.description );
            obj.setDirectory( record.directory );
            obj.setDefault( record.default );
			
			/*
			obj.setVersions(
				getMediaService().getVersions( obj.getPath() )
			)
			*/

			return obj;
			
	    }

    	return NullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "File_#arguments.id#";

  	}

}
