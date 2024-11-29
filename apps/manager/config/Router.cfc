component {

	function configure(){
		var settings = new config.Settings();

		setFullRewrites( true );

		route( "/healthcheck", function(event, rc, prc){
			return "v. #settings( "app.version" )# Ok!";
		} );

		route( "/live", function(event, rc, prc){
			return "<meta http-equiv='refresh' content='60'>
				Live #now()#";
		} );

		get( "/dashboard" ).to( "MainController.dashboard" ).end();

		get( "/plate/designer" ).to( "PlateController.designer" ).end();


		/*
			current account
		*/
		post( "/ajax/change-pwd" ).to( "CurrentUserAjaxController.changePwd" ).end();

		get( "/my/account" ).to( "CurrentUserController.get" ).end();


		/*
			finishes
		*/
		get( "/ajax/finishes/code-exists" ).to( "FinishAjaxController.codeExists" ).end();

		get( "/ajax/finishes" ).to( "FinishAjaxController.list" ).end();

		post( "/ajax/finishes" ).to( "FinishAjaxController.save" ).end();

		get( "/finishes" ).to( "FinishController.list" ).end();


		/*
			components
		*/
		get( "/ajax/components" ).to( "ComponentAjaxController.list" ).end();


		/*
			production times
		*/

		get( "/ajax/production-times").to("ProductionTimeAjaxController.list").end();

		get( "/production-times").to("ProductionTimeController.list").end();


		/*
			auth // login
		*/
		post( "/login/pincode/check" ).toHandler( "AuthController.checkPincode" );

		post( "/login/check" ).toHandler( "AuthController.checkLogin" );

		post( "/login/recover/check" ).toHandler( "AuthController.checkRecover" );

		get( "/login/recover" ).toHandler( "AuthController.recover" );

		get( "/login/pincode" ).toHandler( "AuthController.pincode" );

		get( "/login" ).toHandler( "AuthController.login" );

		get( "/logout" ).toHandler( "AuthController.logout" );


		/*
			accounts
		*/
		get( "/ajax/accounts/email-exists" ).to( "AccountAjaxController.emailExists" ).end();

		get( "/ajax/accounts" ).to( "AccountAjaxController.list" ).end();

		post( "/ajax/accounts" ).to( "AccountAjaxController.save" ).end();
		delete( "/ajax/accounts" ).to( "AccountAjaxController.delete" ).end();

		get( "/accounts" ).to( "AccountController.list" ).end();

		get( "/accounts/print" ).to( "AccountController.print" ).end();


		/*
			fruits
		*/
		get( "/fruits/:id" ).toHandler( "FruitController.get" );

		get( "/fruits" ).toHandler( "FruitController.list" );


		/*
			quotations
		*/
		get( "/quotations/00001/items" ).toHandler( "QuotationController.items" );

		get( "/quotations/:id" ).toHandler( "QuotationController.get" );

		get( "/quotations" ).toHandler( "QuotationController.list" );

		get( "/quotation" ).toHandler( "QuotationController.new" );


		/*
			attribute values
		*/
		get( "/ajax/attributes/values/code-exists" ).to( "AttributeValueAjaxController.codeExists" ).end();

		post( "/ajax/attributes/values" ).to( "AttributeValueAjaxController.save" ).end();

		post( "/ajax/attributes/:id/values/order" ).to( "AttributeValueAjaxController.order" ).end();

		delete( "/ajax/attributes/values" ).to( "AttributeValueAjaxController.delete" ).end();
		


		/*
			attributes
		*/
		get( "/ajax/attributes/new" ).to( "AttributeAjaxController.new" ).end();

		get( "/ajax/attributes/:id" ).to( "AttributeAjaxController.get" ).end();

		post( "/ajax/attributes" ).to( "AttributeAjaxController.save" ).end();

		delete( "/ajax/attributes" ).to( "AttributeAjaxController.delete" ).end();

		get( "/ajax/attributes" ).to( "AttributeAjaxController.list" ).end();

		get( "/attributes" ).to( "AttributeController.list" ).end();


		/*
			reports
		*/
		get( "/ajax/reports/:id" ).toHandler( "ReportAjaxController.get" );

		get( "/ajax/reports" ).toHandler( "ReportAjaxController.list" );

		get( "/reports/:id" ).toHandler( "ReportController.get" );

		get( "/reports" ).toHandler( "ReportController.list" );


		/*
			texts
		*/
		get( "/ajax/texts/:id/all" ).toHandler( "TextAjaxController.all" );

		get( "/ajax/texts/:id" ).toHandler( "TextAjaxController.get" );

		get( "/ajax/texts" ).toHandler( "TextAjaxController.list" );

		get( "/texts" ).toHandler( "TextController.list" );


		/*
			combination
		*/
		post( "/ajax/combinations/:id/items" ).to( "CombinationAjaxController.addItem" ).end();

		get( "/ajax/combinations/:id/items" ).to( "CombinationAjaxController.listItems" ).end();

		//delete( "/ajax/combinations/:id/item" ).to( "CombinationAjaxController.removeItem" ).end();
		delete( "/ajax/combinations/:id/items" ).to( "CombinationAjaxController.removeItems" ).end();

		get( "/combinations/:id" ).to( "CombinationController.detail" ).end();



		/*
			lines category
		*/
		get( "/ajax/product-categories/code-exists" ).to( "ProductCategoryAjaxController.codeExists" ).end();

		get( "/ajax/product-categories" ).to( "ProductCategoryAjaxController.list" ).end();
		post( "/ajax/product-categories" ).to( "ProductCategoryAjaxController.save" ).end();
		
		delete( "/ajax/product-categories" ).to( "ProductCategoryAjaxController.delete" ).end();

		get( "/product-categories" ).to( "ProductCategoryController.list" ).end();


		/*
			lines
		*/
		get( "/ajax/lines/code-exists" ).to( "LineAjaxController.codeExists" ).end();

		delete( "/ajax/lines/:id/combinations" ).to( "LineAjaxController.deleteCombination" ).end();

		post( "/ajax/lines/:id/combinations" ).to( "LineAjaxController.createCombination" ).end();

		get( "/ajax/lines/attributes" ).to( "LineAjaxController.attributes" ).end();

		get( "/ajax/lines/:id" ).to( "LineAjaxController.get" ).end();

		get( "/ajax/lines" ).to( "LineAjaxController.list" ).end();

		post( "/ajax/lines" ).to( "LineAjaxController.save" ).end();

		delete( "/ajax/lines" ).to( "LineAjaxController.delete" ).end();

		get( "/lines/:id/combinations" ).to( "LineController.combinations" ).end();

		get( "/lines/:id/attributes" ).to( "LineController.attributes" ).end();

		get( "/lines" ).to( "LineController.list" ).end();


		/*
			size
		*/
		get( "/ajax/sizes/code-exists" ).to( "SizeAjaxController.codeExists" ).end();

		get( "/ajax/sizes" ).to( "SizeAjaxController.list" ).end();

		post( "/ajax/sizes" ).to( "SizeAjaxController.save" ).end();

		delete( "/ajax/sizes" ).to( "SizeAjaxController.delete" ).end();

		get( "/sizes/print" ).to( "SizeController.print" ).end();

		get( "/sizes" ).to( "SizeController.list" ).end();


		/*
			roles
		*/
		get( "/roles/:id" ).to( "RoleController.get" ).end();

		get( "/roles" ).to( "RoleController.list" ).end();

		get( "/roles/print" ).to( "RolController.print" ).end();

		/*
			system
		*/
		get( "/system" ).to( "SystemController.get" ).end();


		/*
			lookup
			[TODO] "JSDATA" non funziona
		*/
		get( "/(.*)/datajs" ).to( "LookupController.datajs" ).end();


		/*
			catch all
		*/

		// route( ":handler/:action?" ).end();
	}

}
