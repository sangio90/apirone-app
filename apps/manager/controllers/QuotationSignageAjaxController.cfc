component extends="com.apirone.core.controller.AbsController" {

	function list( event, rc, prc ){
		var data = [];

		var result = super.getResult();
		var params = super.paramsFromUrl();
		var mem    = super.getMementify();

		var rows = super.fire(
			"signageConfig.list",
			{
				categoryId = rc.categoryId,
				lineId     = rc.lineId,
				modelId    = rc.modelId
			}
		);

		var data = mem.convertList( rows, "list" );

		result.setTotal( rows.len() );
		result.setCount( rows.len() );
		result.setData( data );

		event.setValue( "result", result );
	}

}
