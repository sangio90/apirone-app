component extends="com.apirone.core.model.service.AbsService" accessors="true" {

    property name="dao" type="com.apirone.core.model.dao.FileDAO";
    property name="lookupService" type="com.apirone.core.model.service.LookupService";
    property name="fileTypeService" type="com.apirone.core.model.service.FileTypeService";

    public com.apirone.core.model.bean.file function get(
    		required String fileId
    	){

    	var cm = getCacheManager();

    	var key = getCacheKey( arguments.fileId );

	   	var cache = cm.get( key ) ;

	    if ( cache.status ) {
	    
	      return cache.data;
	    
	    } 
	    
		var obj = build( arguments.fileId );
		cm.put( key, obj );
	
        return obj;

    }

	public com.apirone.core.model.bean.Result function list(
		String kindId,
		String combinationId,
		String combinationItemId,
	) {
		arguments['limit'] = -1;
		return search(argumentCollection = arguments)
	}


    public com.apirone.core.model.bean.Result function search(
					 String kindId,
					 String combinationId,
					 String combinationItemId,
			required Numeric limit = 20,
			required Numeric offset = 0
    	){

	    var rows = [];
    	var result = super.getResult();

    	var records = getDao().find( argumentCollection=arguments );

		records.each(function(record) {
			rows.add( get( fileId = record.file_id ) );
		});

	    result.setData( rows );
	    result.setCount( Val( records.recordcount ) );
	    result.setTotal( Val( records.total ) );

        return result;

    }

	/*
	public String function create(
			required com.apirone.core.model.bean.File file,
            		 com.apirone.core.model.bean.Entity entity
		){

        return getDao()
        			.insert( argumentCollection = arguments )
            		.toString();

	}
	*/

	public String function update(
			required com.apirone.core.model.bean.File file,
            required com.apirone.core.model.bean.Entity entity
		){
		
            var id = getDao()
                        .update( file = arguments.file, entity = arguments.entity )
                        .toString();
            
			getCacheManager().remove( getCachekey( id ) );
			
			return id;
    
	}

	public void function delete(
		required String fileId
	){

		getDao().delete( arguments.fileId );
		
		getCacheManager().remove( getCachekey( arguments.fileId ) );

	}


	public String function create(
		required String filePath, //full path of file, from /tmp for example
		required String scope, //accounts
		required String fileTypeId,
				 Struct entity,
	){

		var thisFile = "";

		var bean = super.bean("File");
		var type = super.bean("FileType");

		var root = ExpandPath("/../repository/private/" );

		var account = getAccountService().get( arguments.accountId );
		var home = account.getHome();

		var dayPath = DateFormat( now(), "yyyy/mm" )

		var destination = root & "accounts" & "/" & home & "/" & arguments.scope & "/" & dayPath;

		DirectoryCreate( destination, true, true );

		var fileName = ListFirst( ListLast( arguments.filePath, "/" ), "." );
		var fileExt  = ListLast( arguments.filePath, "." );

		var unique = Left( LCase( Replace( CreateUUID(), '-', '', 'ALL' ) ), 5 );
        var name = prettyString( fileName ) & '_' & unique & '.' & LCase( fileExt );
        
		cffile( source="#arguments.filePath#", destination="#destination#/#name#", action="RENAME" );

		var fileInfo = FileInfo( "#destination#/#name#" );
	
		bean.setName( name );
		bean.setDescription('');
		bean.setDirectory( arguments.scope & '/' & dayPath );
		bean.setSize( fileInfo.size );
		bean.setType( type.setId( arguments.fileTypeId ) );
		bean.setAccount( account );
		bean.setEntity( arguments.entity );

		if ( IsImageFile( "#destination#/#name#" ) ) {

			var info = ImageInfo( "#destination#/#name#" );

			bean.setHeight( info.height );
			bean.setWidth( info.width );
			bean.setAlt("");
			bean.setExtension("");
		
		}

		//var result = create( bean );

        getDao()
			.insert( argumentCollection = arguments )
			.toString();


		return result;
	
	}


    /**
     * @private
     */
  	private com.apirone.core.model.bean.file function build(
    		required String fileId
    	){

	    var record = getDao().read( fileId = arguments.fileId );

	    if( record.RecordCount ) { 

	    	var obj = super.bean( "File" );

		    obj.setId( record.file_id.toString() );
            obj.setName( record.name );
			
			// it's documentType!
        	obj.setType( getDocumentTypeService().get( record.type_id ) );
            obj.setSize( record.size );
            obj.setWidth( record.width );
            obj.setHeight( record.height );
            obj.setAlt( record.alt );
            obj.setDescription( record.description );
            obj.setExtension( record.extension );
            obj.setDirectory( record.directory );
            obj.setAccount( getAccountService().get( record.account_id ) );

			return obj;
		
		}

		return nullValue();

  	}

  	private String function getCacheKey( required String id ) {

  		return "file_#arguments.id#";

  	}

}
