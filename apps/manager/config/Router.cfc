
component{

	function configure(){

		var settings = new config.Settings();
		
		setFullRewrites( true );

		route( "/healthcheck", function( event, rc, prc ) {
			return "v. #settings('app.version')# Ok!";
		} );

		route( "/live", function( event, rc, prc ) {
			return "Live #now()#";
		} );

    	get( "/dashboard" )
        	.to( "MainController.dashboard" ).end();

		get(
			"/countries/list"
		).to('CountryController.list').end();


		/*
			plates
		*/
		get(
			"/plates/:id"
		).to('PlateController.edit').end();

		get(
			"/plates"
		).to('PlateController.list').end();		


		/*
			productionTime
		*/

		route( "/ajax/production-times" )
			.withAction( {
				GET = "list",
				POST = "create",
				PUT = "modify"
			} )
			.toHandler( "ProductionTimeAjaxController" );

		get(
			"/production-times"
		).to('ProductionTimeController.list').end();
	
		get(
			"/production-times/:id"
		).to('ProductionTimeController.list').end();


		/*
			components
		*/

		get(
			"/ajax/components"
		).to("ComponentAjaxController.list").end();
		

		/*
			products
		*/

		route( "/ajax/products" )
			.withAction( {
				GET = "list",
				POST = "create",
				PUT = "modify"
			} )
			.toHandler( "ProductAjaxController" );

		get(
			"/products/:productId/components"
		).to('ProductController.components').end();

		get(
			"/products/:productId"
		).to('ProductController.edit').end();

		post(
			"/products"
		).to('ProductController.save').end();
		
		get(
			"/products"
		).to("ProductController.list").end();		


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
			accounts
		*/
		get( "/accounts/:id" )
        	.toHandler( "AccountController.get" );

		get( "/accounts" )
        	.toHandler( "AccountController.list" );

		get( "/accounts/print" )
        	.toHandler( "AccountController.print" );

	
		/*
			fruits
		*/
		get( "/fruits/:id" )
        	.toHandler( "FruitController.get" );

		get( "/fruits" )
        	.toHandler( "FruitController.list" );


		/*
			quotations
		*/
		get( "/quotations/00001/items" )
        	.toHandler( "QuotationController.items" );

		get( "/quotations/:id" )
        	.toHandler( "QuotationController.get" );

		get( "/quotations" )
        	.toHandler( "QuotationController.list" );

		get( "/quotation" )
        	.toHandler( "QuotationController.new" );


		/*
			lines
		*/
		get( "/lines/:id" )
        	.toHandler( "LineController.edit" );

		get( "/lines" )
        	.toHandler( "LineController.list" );

		get( "/ajax/lines" )
        	.toHandler( "LineAjaxController.list" );


		/*
			roles
		*/
		get( "/roles/:id" )
        	.toHandler( "RoleController.get" );

		get( "/roles" )
        	.toHandler( "RoleController.list" );

		get( "/roles/print" )
        	.toHandler( "AccountController.print" );


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
