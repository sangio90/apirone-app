component extends="com.apirone.core.controller.AbsController" {

    function upload( event, rc, prc ){

        var tmpDir = getTempDir();
        var entity = super.bean("Entity");

        if( rc.by == "item" ) {
            entity.setKey( "combinationItemId" );
            entity.setValue( rc.itemId );
        }

        if( rc.by == "combination" ) {
            entity.setKey( "combinationId" );
            entity.setValue( rc.combinationId );
        }

		cffile( filefield=rc.files[1], nameconflict="MAKEUNIQUE", destination=tmpDir, action="UPLOAD" );

        super.fire( "file.create", {  filePath = "#tmpDir#/#cffile.ServerFile#", entity = entity } );

        var result = super.getResult();
        
        result.setData( { "message" = "File caricato" } );

        event.setValue( "result", result );
        
    }

}



