component extends="com.apirone.core.controller.AbsController" {

	/*
		cerco di scrivere questo controller
		come una best practice per tutto quotation
	*/

	function getProductByParams( event, rc, prc ){
		// by modelId, lineId, finishId, rc.categoryId

		var result = super.getResult();
		var memy   = super.getMementify();

		var products = super
			.service( "Product" )
			.list(
				modelId    = rc.modelId,
				lineId     = rc.lineId,
				finishId   = rc.finishId,
				categoryId = rc.categoryId
			);

		if ( ArrayLen( products ) GT 1 ) {
			getLogger().warning( "Products found: #ArrayLen( products )#. Get the first. Should be only one with this params: modelId: #rc.modelId#, lineId: #rc.lineId#, finishId: #rc.finishId#, categoryId: #rc.categoryId#" );
		}

		product = products[ 1 ];

		result.setData( memy.convert( product, "plate" ) );

		event.setValue( "result", result );
	}

	function save( event, rc, prc ){
	}

	function delete( event, rc, prc ){
	}

}
