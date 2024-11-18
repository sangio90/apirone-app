
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

		get("/countries/list")
			.to('CountryController.list').end();

		get("/production-times")
			.to('ProductionTimeController.list').end();
	
		get( "/production-times/:id")
			.to('ProductionTimeController.list').end();


		/*
			finishes
		*/

		get( "/ajax/finishes/code-exists")
			.to("FinishAjaxController.codeExists").end();
		
		get( "/ajax/finishes")
			.to("FinishAjaxController.list").end();
		
		post("/ajax/finishes")
			.to("FinishAjaxController.save").end();
		
		get( "/finishes" )
			.to("FinishController.list").end();
		
		/*
			components
		*/

		get( "/ajax/components")
			.to("ComponentAjaxController.list").end();
		
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
		get( "/ajax/attributes/new" )
        	.to( "AttributeAjaxController.new" ).end();

		post( "/ajax/attributes/values")
        	.to( "AttributeAjaxController.saveValue" ).end();

		post( "/ajax/attributes/:id/values/order")
        	.to( "AttributeAjaxController.order" ).end();

		get( "/ajax/attributes/:id")
        	.to( "AttributeAjaxController.get" ).end();

		post( "/ajax/attributes")
        	.to( "AttributeAjaxController.save" ).end();

		get( "/ajax/attributes")
        	.to( "AttributeAjaxController.list" ).end();

		get("/attributes")
			.to("AttributeController.list").end();
	


		/*
			reports
		*/
		get( "/ajax/reports/:id")
        	.toHandler( "ReportAjaxController.get" );

		get( "/ajax/reports")
        	.toHandler( "ReportAjaxController.list" );

		get( "/reports/:id" )
        	.toHandler( "ReportController.get" );

		get( "/reports" )
        	.toHandler( "ReportController.list" );


		/*
			texts
		*/

		get( "/ajax/texts/:id/all")
        	.toHandler( "TextAjaxController.all" );

		get( "/ajax/texts/:id")
        	.toHandler( "TextAjaxController.get" );

		get( "/ajax/texts")
        	.toHandler( "TextAjaxController.list" );

		get( "/texts" )
        	.toHandler( "TextController.list" );



		/*
			values
		*/


		/*
			combination
		*/

		post( "/ajax/combinations/:id/items" )
			.to( "CombinationAjaxController.addItem" ).end();

		get( "/ajax/combinations/:id/items" )
			.to( "CombinationAjaxController.listItems" ).end();

		delete( "/ajax/combinations/:id/item" )
        	.to( "CombinationAjaxController.removeItem" ).end();

		get( "/combinations/:id")
			.to( "CombinationController.detail" ).end();
		


		/*
			lines category
		*/

		get( "/ajax/lines/categories")
			.to( "LineCategoryAjaxController.list" ).end();
		get( "/lines/categories")
			.toHandler( "LineCategoryController.list" );



		/*
			lines
		*/

		get( "/lines/:id/combinations")
			.toHandler( "LineController.combinations" );

		get( "/lines/:id/attributes")
			.toHandler( "LineController.attributes" );

		get( "/lines/:id" )
        	.toHandler( "LineController.edit" );

		get( "/lines" )
        	.toHandler( "LineController.list" );

		/*
		get( "/ajax/lines/:lineId/size/:sizeId/finish/:finishId/conf" )
        	.toHandler( "LineAjaxController.configuration" );
		
		post( "/ajax/lines/:id/add" )
        	.toHandler( "LineAjaxController.addValue" );
		*/

		delete( "/ajax/lines/:id/combinations")
			.to( "LineAjaxController.deleteCombination" ).end();

		post( "/ajax/lines/:id/combinations")
			.to( "LineAjaxController.createCombination" ).end();

		get( "/ajax/lines/attributes" )
        	.toHandler( "LineAjaxController.attributes" );

		get( "/ajax/lines" )
        	.toHandler( "LineAjaxController.list" );

			
		/*
			size
		*/
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
		get( "/(.*)/datajs" //[TODO] "JSDATA" non funziona
		).to('LookupController.datajs').end();

			
		/*
			catch all
		*/

		//route( ":handler/:action?" ).end();
	
	}

}
