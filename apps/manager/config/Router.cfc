
component{

	function configure(){

		var settings = new config.Settings();
		
		setFullRewrites( true );

		route( "/healthcheck", function( event, rc, prc ) {
			return "v. #settings('app.version')# Ok!";
		} );

		get( "/live" )
        	.toHandler( "UtilController.live" );

    	get( "/dashboard" )
        	.to( "MainController.dashboard" ).end();

		get(
			"/countries/list"
		).to('CountryController.list').end();


		/*
			companies
		*/

		get(
			"/companies/new"
		).to('CompanyController.new').end();

		get(
			"/companies/:companyId"
		).to('CompanyController.edit').end();		
		
		post(
			"/companies/save"
		).to('CompanyController.save').end();
		
		get(
			"/companies"
		).to('CompanyController.list').end();
		

		/*
			products
		*/
		get(
			"/products/new"
		).to('ProductController.new').end();		

		get(
			"/products/:productId"
		).to('ProductController.edit').end();

		post(
			"/products/save"
		).to('ProductController.save').end();
		
		get(
			"/products/:productId/variants"
		).to('ProductController.listVariants').end();
		
		get(
			"/products/:productId/images"
		).to('ProductController.listImages').end();
		
		get(
			"/products"
		).to('ProductController.list').end();		


		/*
			cards
		*/
		get(
			"/card/generate"
		).to('CardController.generate').end();

		post(
			"/cards/generate-do"
		).to('CardController.generateAll').end();

		get(
			"/cards/slots/:id/print"
		).to('CardController.printCardsBySlot').end();

		get(
			"/cards/slots"
		).to('CardController.listSlots').end();

		get(
			"/cards"
		).to('CardController.list').end();		

		/*
			documents
		*/
		get(
			"/documents/:id"
		).to('DocumentController.get').end();

		get(
			"/documents"
		).to('DocumentController.list').end();


		/*
			sales
		*/
		get(
			"/sales/print"
		).to('SaleController.print').end();

		get(
			"/sales"
		).to('SaleController.list').end();
		
				
		/*
			account
		*/
		get( "/my/wallet" )
			.to('CurrentUserController.wallet').end();

		get( "/my/profile" )
			.to('CurrentUserController.profile').end();


		get( "/account/print" )
        	.toHandler( "AccountController.print" );

		get( "/account" )
			.to('AccountController.list').end();


		/*
			cart
		*/
		get( "/cart/:id/delete" )
			.to('CartController.deleteProduct').end();

		post( "/cart/add" )
			.to('CartController.addProduct').end();

		post( "/cart/save" )
			.to('CartController.save').end();

		get( "/cart/empty" )
			.to('CartController.empty').end();

		get( "/cart/complete" )
			.to('CartController.complete').end();

		get( "/cart" )
			.to('CartController.get').end();


		/*
			catalogue
		*/
		get( "/catalogue/products/:id" )
			.to('CatalogueController.product').end();		

		get( "/catalogue/complete" )
			.to('CatalogueController.complete').end();		

		/*
			auth // login
		*/
		post( "/login/pincode/check" )
        	.toHandler( "AuthController.checkPincode" );

		post( "/login/check" )
        	.toHandler( "AuthController.checkLogin" );

		post( "/login/recover/check" )
        	.toHandler( "AuthController.checkRecover" );

		get( "/login/recover" )
        	.toHandler( "AuthController.recover" );

		get( "/login/pincode" )
        	.toHandler( "AuthController.pincode" );

		get( "/login" )
        	.toHandler( "AuthController.login" );

		get( "/logout" )
        	.toHandler( "AuthController.logout" );


		/*
			account
		*/
		get( "/accounts/:id" )
        	.toHandler( "AccountController.get" );

		get( "/accounts" )
        	.toHandler( "AccountController.list" );

		/*
		route( "/accounts/:id?" )
			.withAction( {
				GET : "get",
				POST : "save",
				PUT : "update",
				DELETE : "remove"
			} )
			.toHandler( "AccountController" );
		*/
		

		/*
			lookup
		*/
		get(
			"/(.*)/datajs" //[TODO] "JSDATA" non funziona
		).to('LookupController.datajs').end();

			
		/*
			catch all
		*/

		//route( ":handler/:action?" ).end();
	
	}

}
