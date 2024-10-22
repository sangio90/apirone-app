
component{

	function configure(){

		var settings = new config.Settings();
		
		setFullRewrites( true );

		route( "/healthcheck", function( event, rc, prc ) {
			return "v. #settings('app.version')# Ok!";
		} );

		route( "/live", function( event, rc, prc ) {
			return "<meta http-equiv='refresh' content='60'>
				Live #now()#";
		} );

    	get( "/dashboard" )
        	.to( "MainController.dashboard" ).end();

		get("/countries/list"
		).to('CountryController.list').end();


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
			attributes
		*/
		get( "/ajax/attributes/exists")
			.toHandler( "AttributeAjaxController.idExists" );

		get( "/ajax/attributes/new" )
        	.toHandler( "AttributeAjaxController.new" );

		get( "/ajax/attributes/:id")
        	.toHandler( "AttributeAjaxController.get" );

		get( "/ajax/attributes")
        	.to( "AttributeAjaxController.list" ).end();

		post( "/ajax/attributes")
        	.to( "AttributeAjaxController.save" ).end();

		/*
			values
		*/
		get( "/ajax/values/attribute/:attributeId")
        	.toHandler( "AttributeValueAjaxController.list" );

		post( "/ajax/values/:attributeId")
        	.to( "AttributeValueAjaxController.save" ).end();


		/*
			lines
		*/
		get( "/lines/:id/attributes")
			.toHandler( "LineController.attributes" );

		get( "/lines/:id" )
        	.toHandler( "LineController.edit" );

		get( "/lines" )
        	.toHandler( "LineController.list" );

		get( "/ajax/lines" )
        	.toHandler( "LineAjaxController.list" );
	
		get( "/ajax/lines/attributes" )
        	.toHandler( "LineAjaxController.attributes" );
	

		/*
			size
		*/
		get( "/sizes/:id" )
        	.toHandler( "SizeController.get" );

		get( "/sizes" )
        	.toHandler( "SizeController.list" );

		get( "/ajax/sizes" )
        	.toHandler( "SizeAjaxController.list" );

		get( "/sizes/print" )
        	.toHandler( "SizeController.print" );


		/*
			roles
		*/
		get( "/roles/:id" )
        	.toHandler( "RoleController.get" );

		get( "/roles" )
        	.toHandler( "RoleController.list" );

		get( "/roles/print" )
        	.toHandler( "RolController.print" );


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
