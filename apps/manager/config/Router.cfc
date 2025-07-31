component {

	function configure(){
		var settings = new config.Settings();

		setFullRewrites( true );

		route( "/healthcheck", function(event, rc, prc){
			return "v. #settings( "app.version" )# Ok!";
		} );

		get( "/tmp" ).to( "MainController.tmp" ).end();

		route( "/live", function(event, rc, prc){
			return "<meta http-equiv='refresh' content='60'>
				Live #now()#";
		} );

		/*
			dashboard
		*/
		get( "/dashboard" ).to( "MainController.dashboard" ).end();
		get( "/plate/designer" ).to( "PlateController.designer" ).end();
		get( "/plate/map" ).to( "PlateController.map" ).end();


		/*
			fruits
		*/
		get( "/ajax/fruits/code-exists" ).to( "FruitAjaxController.codeExists" ).end();
		post( "/ajax/fruits/:id/items" ).to( "FruitAjaxController.addItem" ).end();
		get( "/ajax/fruits/:id/items" ).to( "FruitAjaxController.listItems" ).end();
		get( "/ajax/fruits/:id" ).to( "FruitAjaxController.get" ).end();
		get( "/ajax/fruits" ).to( "FruitAjaxController.list" ).end();
		post( "/ajax/fruits" ).to( "FruitAjaxController.save" ).end();
		delete( "/ajax/fruits" ).to( "FruitAjaxController.delete" ).end();
		get( "/fruits" ).to( "FruitController.list" ).end();


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
			raw value
		*/
		//get( "/ajax/raw-value" ).to( "RawValueAjaxController.new" ).end();
		//get( "/ajax/raw-value/:id" ).to( "RawValueAjaxController.get" ).end();
		get( "/ajax/raw-values/code-exists" ).to( "RawValueAjaxController.codeExists" ).end();
		get( "/ajax/raw-values/:id" ).to( "RawValueAjaxController.get" ).end();
		post( "/ajax/raw-values" ).to( "RawValueAjaxController.save" ).end();
		delete( "/ajax/raw-values" ).to( "RawValueAjaxController.delete" ).end();
		get( "/ajax/raw-values" ).to( "RawValueAjaxController.list" ).end();
		get( "/raw-values" ).to( "RawValueController.list" ).end();

		/*
			products
		*/
		get( "/ajax/raw-products" ).to( "RawProductAjaxController.list" ).end();


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
			attribute values
		*/
		post( "/ajax/attributes/:id/raw-values/add" ).to( "AttributeValueAjaxController.addValue" ).end();
		post( "/ajax/attributes/:id/raw-values/sort" ).to( "AttributeValueAjaxController.sort" ).end();
		delete( "/ajax/attributes/:id/raw-values" ).to( "AttributeValueAjaxController.deleteValues" ).end();


		/*
			attributes
		*/
		get( "/ajax/attributes/code-exists" ).to( "AttributeAjaxController.codeExists" ).end();
		get( "/ajax/attributes/raw-values" ).to( "AttributeAjaxController.listRawValues" ).end();
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
			components
		*/
		get( "/ajax/components" ).to( "ComponentAjaxController.list" ).end();
		post( "/ajax/components" ).to( "ComponentAjaxController.save" ).end();


		/*
			products
		*/
		get( "/ajax/:by-regex:(products|product-items|combinations)/:id/images" ).to( "FileAjaxController.list" ).end();
		post( "/ajax/:by-regex:(products|product-items|combinations)/:id/images" ).to( "FileAjaxController.upload" ).end();
		delete( "/ajax/:by-regex:(products|product-items|combinations)/:id/images" ).to( "FileAjaxController.delete" ).end();

		get( "/ajax/products/code-exists" ).to( "ProductAjaxController.codeExists" ).end();
		get( "/ajax/products/:id/combinations/calculate" ).to( "ProductAjaxController.calculateCombinations" ).end();
		delete( "/ajax/products/:id/combinations" ).to( "ProductAjaxController.deleteCombinations" ).end();
		get( "/ajax/products/:id/combinations" ).to( "ProductAjaxController.combinations" ).end();
		post( "/ajax/products/:id/items/order" ).to( "ProductAjaxController.sortItems" ).end();
		get( "/ajax/products/:id/items/order" ).to( "ProductAjaxController.listItemsForSort" ).end();
		get( "/ajax/products/:id/attributes/order" ).to( "ProductAjaxController.listAttributesForSort" ).end();
		post( "/ajax/products/:id/attributes/order" ).to( "ProductAjaxController.sortAttributes" ).end();
		post( "/ajax/products/:id/items" ).to( "ProductAjaxController.addItem" ).end();
		post( "/ajax/products/:id/values" ).to( "ProductAjaxController.addValue" ).end();
		get( "/ajax/products/:id/items" ).to( "ProductAjaxController.listItems" ).end();
		delete( "/ajax/products/:id/items" ).to( "ProductAjaxController.removeItems" ).end();
		get( "/ajax/products/:id" ).to( "ProductAjaxController.get" ).end();
		delete( "/ajax/products" ).to( "ProductAjaxController.delete" ).end();
		post( "/ajax/products" ).to( "ProductAjaxController.save" ).end();
		get( "/ajax/products" ).to( "ProductAjaxController.list" ).end();
		get( "/products/:id/combinations" ).to( "ProductController.combinations" ).end();

		get( "/products/category/:id" ).to( "ProductController.listByCategoryId" ).end();
		get( "/products/:id" ).to( "ProductController.detail" ).end();
		//get( "/comb/:id/items" ).to( "ProductController.items" ).end();


		/*
			product category
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
		get( "/ajax/lines/categories/:categoryId" ).to( "LineAjaxController.listByCategoryId" ).end();
		delete( "/ajax/lines/:id/products" ).to( "LineAjaxController.deleteProduct" ).end();
		post( "/ajax/lines/:id/products" ).to( "LineAjaxController.createProduct" ).end();
		get( "/ajax/lines/attributes" ).to( "LineAjaxController.attributes" ).end();
		get( "/ajax/lines/:id" ).to( "LineAjaxController.get" ).end();
		get( "/ajax/lines" ).to( "LineAjaxController.list" ).end();
		post( "/ajax/lines" ).to( "LineAjaxController.save" ).end();
		delete( "/ajax/lines" ).to( "LineAjaxController.delete" ).end();
		
		get( "/lines/categories/:categoryId" ).to( "LineController.listByCategoryId" ).end();
		get( "/lines/categories" ).to( "LineController.listByCategoryId" ).end();
		get( "/lines/:id/categories/:categoryId/products" ).to( "LineController.products" ).end(); //TODO: better naming
		get( "/lines/:id/attributes" ).to( "LineController.attributes" ).end();
		get( "/lines" ).to( "LineController.list" ).end();

		/*
			size configs
		*/
		post( "/ajax/size_config" ).to( "SizeConfigAjaxController.save" ).end();


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
			profiles
		*/
		get( "/ajax/profiles/:id" ).to( "ProfileAjaxController.get" ).end();
		get( "/ajax/profiles" ).to( "ProfileAjaxController.list" ).end();


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

	}

}
