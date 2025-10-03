component {

	function configure(){
		var settings = new config.Settings();

		setFullRewrites( true );

		get( "/tmp" ).to( "MainController.tmp" ).end();

		route( "/live", function(event, rc, prc){
			return "<meta http-equiv='refresh' content='120'>
				Live #now()#";
		} );

		/*
			dashboard
		*/
		get( "/dashboard" ).to( "MainController.dashboard" ).end();
		//get( "/manager/selects" ).to( "MainController.selects" ).end();
		get( "/plate/designer" ).to( "PlateController.designer" ).end();
		get( "/plate/map" ).to( "PlateController.map" ).end();

		
		/*
			prices
		*/
		post( "/ajax/prices/reassign" ).to( "PriceAjaxController.reassign" ).end();
		get( "/prices" ).to( "PriceController.manage" ).end();

		get( "/ajax/:by-regex:(products)/:id/prices" ).to( "PriceAjaxController.list" ).end();
		post( "/ajax/:by-regex:(products)/:id/prices" ).to( "PriceAjaxController.save" ).end();
		



		/*
			catalog bundle
		*/
		get( "/ajax/catalog-bundles" ).to( "CatalogBundleAjaxController.list" ).end();
		post( "/ajax/catalog-bundles" ).to( "CatalogBundleAjaxController.save" ).end();
		delete( "/signages/catalog-bundles" ).to( "CatalogBundleAjaxController.delete" ).end();
		get( "/catalog-bundles" ).to( "CatalogBundleController.list" ).end();


		/*
			signages
		*/
		post( "/ajax/signages/rows-config" ).to( "SignageConfigAjaxController.save" ).end();
		get( "/signages/rows-config/:id" ).to( "SignageConfigController.rowConfig" ).end();
		get( "/signages/rows-config" ).to( "SignageConfigController.rowConfig" ).end();

		/*
			metadata type
		*/
		get( "/ajax/metadata-types/code-exists" ).to( "MetadataTypeAjaxController.codeExists" ).end();
		get( "/ajax/metadata-types/:id" ).to( "MetadataTypeAjaxController.get" ).end();
		post( "/ajax/metadata-types" ).to( "MetadataTypeAjaxController.save" ).end();
		get( "/ajax/metadata-types" ).to( "MetadataTypeAjaxController.list" ).end();
		delete( "/ajax/metadata-types" ).to( "MetadataTypeAjaxController.delete" ).end();
		get( "/metadata-types" ).to( "MetadataTypeController.list" ).end();

		/*
			metadata
		*/
		get( "/ajax/:by-regex:(raw-values)/:id/metadata" ).to( "MetadataAjaxController.list" ).end();
		post( "/ajax/:by-regex:(raw-values)/:id/metadata" ).to( "MetadataAjaxController.save" ).end();


		get( "/ajax/metadata" ).to( "MetadataTypeAjaxController.list" ).end();
		delete( "/ajax/metadata" ).to( "MetadataTypeAjaxController.delete" ).end();
		get( "/metadata" ).to( "MetadataTypeController.list" ).end();

		/*
			audit entry
		*/
		get( "/ajax/audit-entries/:id" ).to( "AuditEntryAjaxController.get" ).end();
		get( "/ajax/audit-entries" ).to( "AuditEntryAjaxController.list" ).end();
		get( "/audit-entries" ).to( "AuditEntryController.list" ).end();


		/*
			fruits
		*/
		get( "/ajax/fruits/code-exists" ).to( "FruitAjaxController.codeExists" ).end();
		//TODO: consider to remove the 2 follow routes ("/items")
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
		get( "/my/settings" ).to( "CurrentUserController.settings" ).end();


		/*
			finishes
		*/
		get( "/ajax/finishes/code-exists" ).to( "FinishAjaxController.codeExists" ).end();
		get( "/ajax/finishes" ).to( "FinishAjaxController.list" ).end();
		post( "/ajax/finishes" ).to( "FinishAjaxController.save" ).end();
		delete( "/ajax/finishes" ).to( "FinishAjaxController.delete" ).end();
		get( "/finishes" ).to( "FinishController.list" ).end();


		/*
			raw value
		*/
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
		get( "/ajax/production-times/:id").to("ProductionTimeAjaxController.get").end();
		post( "/ajax/production-times").to("ProductionTimeAjaxController.save").end();
		delete( "/ajax/production-times").to("ProductionTimeAjaxController.delete").end();
		get( "/ajax/production-times").to("ProductionTimeAjaxController.list").end();
		get( "/production-times").to("ProductionTimeController.list").end();

		/*
			fonts
		*/
		get( "/ajax/fonts/code-exists" ).to( "FontAjaxController.codeExists" ).end();
		get( "/ajax/fonts/:id" ).to( "FontAjaxController.get" ).end();
		delete( "/ajax/fonts" ).to( "FontAjaxController.delete" ).end();
		get( "/ajax/fonts").to("FontAjaxController.list").end();
		post( "/ajax/fonts" ).to( "FontAjaxController.save" ).end();
		get( "/fonts").to("FontController.list").end();


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
		post( "/ajax/accounts/pwd" ).to( "AccountAjaxController.updatePwd" ).end();
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
			frames
		*/
		get( "/ajax/frames/code-exists" ).to( "FrameAjaxController.codeExists" ).end();
		get( "/ajax/frames/:id" ).to( "FrameAjaxController.get" ).end();
		delete( "/ajax/frames" ).to( "FrameAjaxController.delete" ).end();
		post( "/ajax/frames" ).to( "FrameAjaxController.save" ).end();
		get( "/ajax/frames" ).to( "FrameAjaxController.list" ).end();
		get( "/frames" ).to( "FrameController.list" ).end();


		/*
			reassign components
		*/
		get( "/components/reassign" ).to( "ComponentController.list" ).end();
		post( "/ajax/components/reassign" ).to( "ComponentAjaxController.reassign" ).end();
		delete( "/ajax/components/delete" ).to( "ComponentAjaxController.massiveDelete" ).end();
		/*
			components
		*/
		get( "/ajax/components" ).to( "ComponentAjaxController.list" ).end();
		post( "/ajax/components" ).to( "ComponentAjaxController.save" ).end();

		/*
			files
		*/
		delete( "/ajax/files/:id" ).to( "FileAjaxController.delete" ).end();

		/*
			products
		*/
		get( "/ajax/:by-regex:(products|product-items|combinations|attributes-values)/:id/images" ).to( "FileAjaxController.list" ).end();
		post( "/ajax/:by-regex:(products|product-items|combinations|attributes-values)/:id/images" ).to( "FileAjaxController.upload" ).end();

		get( "/ajax/products/get-id-and-file-by-params" ).to( "ProductAjaxController.getIdAndFileByParams" ).end();
		get( "/ajax/products/code-exists" ).to( "ProductAjaxController.codeExists" ).end();
		get( "/ajax/product-items" ).to( "ProductAjaxController.productItems" ).end();
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
		get( "/products/print/:id" ).to( "ProductController.print" ).end();
		get( "/products/:id/combinations" ).to( "ProductController.combinations" ).end();
		get( "/products/category/:id" ).to( "ProductController.listByCategoryId" ).end();
		get( "/products/:id" ).to( "ProductController.detail" ).end();
		get( "/products" ).to( "ProductController.list" ).end();


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
		post( "/ajax/lines/clone" ).to( "LineAjaxController.clone" ).end();
		get( "/ajax/lines/code-exists" ).to( "LineAjaxController.codeExists" ).end();
		get( "/ajax/lines/categories/:categoryId" ).to( "LineAjaxController.listByCategoryId" ).end();
		post( "/ajax/lines/categories/:categoryId" ).to( "LineAjaxController.saveMarkup" ).end();
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
		get( "/lines/:id/categories/:categoryId/attributes" ).to( "LineController.attributes" ).end();
		get( "/lines" ).to( "LineController.list" ).end();


		/*
			model configs
		*/
		get( "/ajax/model-config/get-by-params" ).to( "ModelConfigAjaxController.getByParams" ).end();
		post( "/ajax/model-config/" ).to( "ModelConfigAjaxController.save" ).end();


		/*
			model
		*/
		get( "/ajax/models/code-exists" ).to( "ModelAjaxController.codeExists" ).end();
		get( "/ajax/models" ).to( "ModelAjaxController.list" ).end();
		post( "/ajax/models" ).to( "ModelAjaxController.save" ).end();
		delete( "/ajax/models" ).to( "ModelAjaxController.delete" ).end();
		get( "/models/print" ).to( "ModelController.print" ).end();
		get( "/models" ).to( "ModelController.list" ).end();


		/*
			profiles
		*/
		get( "/ajax/profiles/:id" ).to( "ProfileAjaxController.get" ).end();
		get( "/ajax/profiles" ).to( "ProfileAjaxController.list" ).end();


		/*
			quotations
		*/
		get( "/ajax/quotations/categories" ).to( "QuotationAjaxController.listCategories" ).end();
		get( "/ajax/quotations/lines/:categoryId" ).to( "QuotationAjaxController.listLines" ).end();
		get( "/ajax/quotations/models/:lineId" ).to( "QuotationAjaxController.listModels" ).end();
		get( "/ajax/quotations/crmcustomers" ).to( "QuotationAjaxController.crmCustomers" ).end();
		get( "/ajax/quotations/finishes/:categoryId/:lineId" ).to( "QuotationAjaxController.listFinishes" ).end();
		get( "/ajax/quotations/signage-configs" ).to( "QuotationSignageAjaxController.list" ).end();
		get( "/ajax/quotations/signage/:id" ).to( "QuotationItemAjaxController.get" ).end();
		
		get( "/quotations/new" ).to( "QuotationController.new" ).end();
		get( "/quotations/:id" ).to( "QuotationController.edit" ).end();
		post( "/quotations" ).to( "QuotationController.create" ).end(); //Da togliere
		get( "/quotations" ).to( "QuotationController.list" ).end();
		
		get( "/ajax/quotations/:quotationId/zones" ).to( "QuotationZoneAjaxController.list" ).end();
		post( "/ajax/quotations/zones" ).to( "QuotationZoneAjaxController.save" ).end();
		delete( "/ajax/quotations/zones" ).to( "QuotationZoneAjaxController.delete" ).end();

		get( "/ajax/quotations" ).to( "QuotationAjaxController.list" ).end();
		delete( "/ajax/quotations" ).to( "QuotationAjaxController.delete" ).end();
		post("/ajax/quotations").to( "QuotationAjaxController.save" ).end();
		
		delete( "/ajax/quotation-items/signagerow" ).to( "QuotationSignageAjaxController.deleteRow" ).end();
		get( "/ajax/quotation-items/signage/:id" ).to( "QuotationItemAjaxController.editSignage" ).end();
		get( "/ajax/quotation-items/:id/product-items" ).to( "QuotationItemAjaxController.productItems" ).end();
		delete("/ajax/quotation-items").to( "QuotationItemAjaxController.delete" ).end();
		get( "/ajax/quotation-items" ).to( "QuotationItemAjaxController.list" ).end();
		post("/ajax/quotation-items").to( "QuotationItemAjaxController.save" ).end();
		

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
