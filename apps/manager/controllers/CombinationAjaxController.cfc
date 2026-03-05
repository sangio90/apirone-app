component extends="com.apirone.core.controller.AbsController" {

	function findByListOfProductItemIds( event, rc, prc ){
		var result = super.getResult();
		var row = super.fire( "combination.findByListOfProductItemIds", [ rc.productItemIds ] );

		var data = {
			"row": row,
			"horizontalImage": null
		};

		if (!IsNull(row)) {
			var combinationImage = super.fire( "file.list", [ combinationId = row.getId() ] );
			data.horizontalImage = len(combinationImage) ? combinationImage[1].getUri() : null;
		}

		result.setData( data );
		event.setValue( "result", result );
	}
}
