component extends="com.apirone.core.controller.AbsController" {

    function list( event, rc, prc ){

        param rc.by = "____";
        var data = [];

        var item = {};

        var file = super.bean("File");

        if( rc.by == "products" ) {
            var params = { productId = rc.id }
            var config = getConfiguration().get("imagesConfig")[ "product" ];
        }

        if( rc.by == "product-items" ) {
            var params = { productItemId = rc.id }
            var config = getConfiguration().get("imagesConfig")[ "productItem" ];
        }

        if( rc.by == "combinations" ) {
            var params = { combinationId = rc.id }
            var config = getConfiguration().get("imagesConfig")[ "combination" ];
        }

        for( var typeId in config.types  ) {

            params.put("typeId", typeId );

            var images = super.fire( "file.list", params );

            // esiste l'immagine
            if( images.len() ) {

                var image = images[1];

                var json = DESerializeJSON( SerializeJSON( image ) );

                json["complete"] = true;
                json["uri"] = image.getUri();
                json["shortId"] = Right( image.getId(), 5 );


            // se non esiste, servo un'immagine vuota
            } else {

                var type = super.fire("fileType.get", [ typeId ] );

                file.setType( type );

                file.setId( "" );
                file.setName("");
                file.setDirectory("");

                var json = DESerializeJSON( SerializeJSON( file ) );

                json["complete"] = false;
                json["uri"] = "";
                json["shortId"] = "";

            }

            data.add( json );

        }

        event.setValue( "result", data );

    }

    function upload( event, rc, prc ){

        var tmpDir = getTempDir();
        var entity = super.bean("Entity");

        if( rc.by == "product-items" ) {
            entity.setKey( "productItem.id" );
            var kindId = "productItem";
        }

        if( rc.by == "products" ) {
            entity.setKey( "product.id" );
            var kindId = "product";
        }

        if( rc.by == "combinations" ) {
            entity.setKey( "combination.id" );
            var kindId = "combination";
        }

        entity.setValue( rc.id );

		cffile( filefield=rc.files[1], nameconflict="MAKEUNIQUE", destination=tmpDir, action="UPLOAD" );

        if( Len( rc.imageId ) ) {
            super.fire( "file.delete", { fileId = rc.imageId } );
        }

        var fileId = super.fire( "file.create", { filePath = "#tmpDir#/#cffile.ServerFile#", entity = entity, typeId=rc.typeId, kindId=kindId } );

        var result = super.getResult();

        var file = super.fire( "file.get", [ fileId ] );

        var message = super.completeMessage( "file.imageCreated" );

        result.setData(
            {
                "message" = message,
                "payload" = {
                    "imageId" = file.getId()
                }
            }
        );

        event.setValue( "result", result );

    }

}
