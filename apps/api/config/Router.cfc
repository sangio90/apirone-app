component {

	function configure(){

		setFullRewrites( true );

		route( "/products/:productId/variants" )
			.withAction( {
				POST : "create",
				PUT : "modify"
			} )
			.toHandler( "ProductVariantController" );

			
		route( "/variants/:productVariantId" )
			.withAction( {
				GET : "get",
				DELETE : "delete"
			} )
			.toHandler( "ProductVariantController" );


		route( "/products/:productId" )
			.withAction( {
				GET : "get",
				DELETE : "delete"
			} )
			.toHandler( "ProductController" );

		
		route( "/products" )
			.withAction( {
				GET : "search",
				POST : "create",
				PUT : "modify"
			} )
			.toHandler( "ProductController" );

		post(
			"/file/delete"
		).to('FileController.delete').end();

		route( "/files/:entity/:entityId" )
			.withAction( {
				POST : "create",
				PUT : "modify"
			} )
			.toHandler( "FileController" );

	}

}
