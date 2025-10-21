component extends="com.apirone.core.model.service.AbsService" accessors="true" {

	variables.baseDir = ExpandPath( "/../repository/public/media" );

	public Struct function getVersions( required String filePath ){
		var baseUrl = super.getConfiguration().get( "filesHost" );

		var imgUrl = "#baseUrl#/media/#filePath#";

		var config = super.getConfiguration();

		var versions = config.get( "imageVersions.models" );

		result = Duplicate( versions ).append( Duplicate( config.get( "imageVersions.crops" ) ) );
		result.append( { "original" = imgUrl } );

		for ( var key in result ) {
			var value     = result[ key ];
			result[ key ] = Replace( imgUrl, "/_ori/", "/#value#/" )
		}

		return result
	}

	public Struct function create( required String filePath, required String category = "variants" ){
		var fileName = getUniqueName( filePath );

		var udf = new com.apirone.core.util.Udf();

		var dateDir = "#Year( Now() )#/#udf.pad( Month( Now() ), 2, "0" )#";

		var directory = "#variables.baseDir#/#arguments.category#/_ori/#dateDir#/";

		DirectoryCreate( directory, true, true );

		var result = "#directory#/#fileName#";

		FileCopy( source = filePath, destination = result );

		remodelAndCrop(
			filePath = result,
			category = arguments.category,
			dateDir  = dateDir
		);

		return {
			"fileName"  = fileName,
			"directory" = "/#arguments.category#/_ori/#dateDir#"
		};
	}

	private Void function remodelAndCrop(
		required String category,
		required String filePath,
		required String dateDir
	){
		/*
        var directory = "#variables.baseDir#/#arguments.category#/";

        var fileName = ListLast( filePath, '/');

        var file = ImageNew(  filePath  );

        var models = super.getConfiguration().get( "imageVersions.models" );
        var crops = super.getConfiguration().get( "imageVersions.crops" );

        models.each((key) => {

            var model = models[key];

            var modelPath = '#directory#/#model#/#dateDir#';

            DirectoryCreate( modelPath, true, true )
            ImageRemodel(file, model );

            file.write( '#modelPath#/#fileName#', true)

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

                ImageRemodel( file, '', height);
                startX = ( ImageGetWidth(file) - ImageGetHeight(file) ) / 2
                startY = 0;

            } else   {

                ImageRemodel( file, width, '' );
                startY = ( ImageGetHeight(file) - ImageGetWidth(file) ) / 2
                startX = 0;
            }

            file.crop( startX, startY, height, width );

            modelPath = "#directory#/#crop#/#dateDir#";

            DirectoryCreate( modelPath, true, true );

            file.write( "#modelPath#/#fileName#", true)

        })
            */
	}

	private String function getUniqueName( required String filePath ){
		var udf = new com.apirone.core.util.Udf();

		var name     = ListFirst( ListLast( filePath, "/" ), "." );
		var thisName = "#udf.prettyString( "#name#" )#_#RandRange( 1, 9000 )#";
		var ext      = ListLast( filePath, "." );

		return "#thisName#.#ext#";
	}

}
