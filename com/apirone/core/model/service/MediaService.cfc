component extends="com.apirone.core.model.service.AbsService" accessors="true" {

    variables.baseDir = ExpandPath('/') & '../repository/public/media';

    public Struct function getVersions( 
        required String filePath
    ) {

        var baseUrl = super.getConfiguration().get('filesHost');

        var imgUrl = "#baseUrl#/media/#filePath#";

        var config = super.getConfiguration();

        var versions = config.get( 'imageVersions.sizes');

        result = Duplicate( versions ).append( Duplicate( config.get( 'imageVersions.crops') ) );
        result.append( {'original': imgUrl });
        
        for ( var key in result ) {
            var value = result[key];
            result[key] = Replace( imgUrl, '/_ori/', "/#value#/" )
        }

        return result
        
    }

    
    public Struct function getVersions( 
        required String filePath
    ) {

        var baseUrl = super.getConfiguration().get('filesHost');

        var imgUrl = "#baseUrl#/media/#filePath#";

        var config = super.getConfiguration();

        var versions = config.get( 'imageVersions.sizes');

        result = Duplicate( versions ).append( Duplicate( config.get( 'imageVersions.crops') ) );
        result.append( {'original': imgUrl });
        
        for ( var key in result ) {
            var value = result[key];
            result[key] = Replace( imgUrl, '/_ori/', "/#value#/" )
        }

        return result
        
    }

    public Struct function create(
        required String filePath,
        required String entity = 'variants'
    )  {    

        var fileName = getUniqueName( filePath );

        var udf = new com.apirone.core.util.Udf();

		var dateDir = '#year(now())#/#udf.pad(month(now()), 2, "0")#';

        var directory = '#variables.baseDir#/#entity#/_ori/#dateDir#/';

        DirectoryCreate(  '#directory#', true, true );

        var result = '#directory#/#fileName#';
        
        fileCopy(source=filePath, destination = result);
        
        resizeAndCrop( filePath = result, entity=entity, dateDir = dateDir );

        return {
            "fileName": fileName,
            "directory": "/#entity#/_ori/#dateDir#"
        };
        
    }

        public Void function resizeAndCrop(
            required String entity,
    		required String filePath,
            required String dateDir
        ){
  

        var directory = "#variables.baseDir#/#entity#/";

        var fileName = ListLast( filePath, '/');

        var file = ImageNew(  filePath  );

        var sizes = super.getConfiguration().get( 'imageVersions.sizes' )
        var crops = super.getConfiguration().get( 'imageVersions.crops' )

        sizes.each((key) => {

            var size = sizes[key];

            var sizePath = '#directory#/#size#/#dateDir#';

            DirectoryCreate( sizePath, true, true )
            ImageResize(file, size );

            file.write( '#sizePath#/#fileName#', true)

        })

        crops.each((key) => {
            var crop = crops[key];
            var height = ListFirst(crop, 'x');
            var width = ListLast( crop, 'x');

            var file = ImageNew( ExpandPath( filePath ) );

            var originalWidth = ImageGetWidth(file);
            var originalHeight = ImageGetHeight(file);
            
            var startX;
            var startY;

            // If horizontal
            if ( originalWidth > originalHeight  )  {

                ImageResize(file,  '', height);
                startX = (ImageGetWidth(file) - ImageGetHeight(file)) / 2
                startY = 0;

            } else   {

                ImageResize(file, width, ''  );
                startY = (ImageGetHeight(file) - ImageGetWidth(file)) / 2
                startX = 0;
            }

            file.crop( startX, startY, height, width );
         
            sizePath = '#directory#/#crop#/#dateDir#';

            DirectoryCreate( sizePath, true, true );
            
            file.write( '#sizePath#/#fileName#', true)

        })

	}

    private  String  function getUniqueName(
        required String filePath
    ) {

        var udf = new com.apirone.core.util.Udf();

        var name = ListFirst( ListLast( filePath, '/'), '.' );
        var resultName = "#udf.prettyString( "#name#")#_#randRange(1,9000)#";
        var ext = ListLast( filePath, '.');
        
        return "#resultName#.#ext#";
    }

}
