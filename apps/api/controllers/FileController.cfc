component extends="com.apirone.core.controller.AbsController" {

	function create( event, rc, prc ) {
		
		var files = DeserializeJSON( getHTTPRequestData().content );

		
		var fileResult = files.map( (file) => {

			var type = ListFirst( file, ':' );
			var result;
			var tmpPath;
			var ext;
			
			if ( type EQ 'https' OR type EQ 'http' ) {

				Cfhttp( method = "GET", url=file, result="data");
				result = data.fileContent;
				ext = ListLast( file, '.');

				tmpPath = ExpandPath('/') & '../repository/private/tmp/#ListLast(file, '/')#';

			} else if ( type EQ 'base64') {

				result = ToBinary( ListLast( file, ':'));
				ext =	ListLast(fileGetMimeType(result), '/' );

				tmpPath = ExpandPath('/') & '../repository/private/tmp/#CreateUUID()#.#ext#';
	
			}

			FileWrite( file=tmpPath, data= result);
	
			var createResult = super.service('Media')
									.create(filePath = tmpPath, entity = rc.entity);

			var file = super.bean('File');

			
			var entity = getEntity(rc.entity)
			
			file.setName( createResult.fileName );
			file.setDirectory( createResult.directory );
			
			var fileService = super.service('File');

			var fileId = fileService.create(file = file, entity = entity);

			return fileService.get( fileId );

		})

		var result = super.getResult();
        result.setData( fileResult );

        event
            .getResponse()
            .setData( result )
        

	}


	function delete( event, rc, prc ) {
		
		var fileIds = DeserializeJSON( getHTTPRequestData().content );

		fileIds.each( (fileId) => {

			var fileService = super.service('File');
			return fileService.delete( fileId );

		})

		var result = super.getResult();
        result.setData( 'filesDeleted' );

        event
            .getResponse()
            .setData( result )
        

	}


	private com.apirone.core.model.bean.Entity function getEntity(required String entity) {

		var type;

		switch ( entity) {
			case 'variants':
				type = 'PV';
				break;
			default:
				break;
		}

		var entity = super.bean('Entity');
		entity.setType(type);
		entity.setId(rc.entityId);

		return entity
	}

}	