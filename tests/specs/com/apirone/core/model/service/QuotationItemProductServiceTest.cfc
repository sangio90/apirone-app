component extends="tests.utils.AbsSpec" {

	function run( testResults, testBox ){
		describe( "QuotationItemProductService", function(){
			beforeEach( function(){
                quotationSvc = getContainer().getInstance( "QuotationService" );
				quotationItemSvc = getContainer().getInstance( "QuotationItemService" );
				svc = getContainer().getInstance( "QuotationItemProductService" );
				productSvc = getContainer().getInstance( "ProductService" );
				helper = super.getHelperData();
			} );

			it( "Create quotation item product", function(){
				var quotationBean = helper.createQuotation();
				var newQuotationId = quotationSvc.create( quotationBean.obj );
				var quotationItemBean = helper.createQuotationItem( quotationId=newQuotationId );
				var newQuotationItemId = quotationItemSvc.create( quotationItemBean.obj );
				var bean = helper.createQuotationItemProductParent( quotationItemId=newQuotationItemId );
				var newId = svc.create( bean.obj );
				var result = svc.get( newId );

				expect( newId == result.getId() ).toBeTrue();
				expect( IsInstanceOf( result, "com.apirone.core.model.bean.QuotationItemProduct" ) ).toBeTrue();
				
                svc.delete( newId );
				quotationItemSvc.delete( newQuotationItemId );
				quotationSvc.delete( newQuotationId );
			} );

			it( "Create quotation item product with parent", function(){
				var quotationBean = helper.createQuotation();
				var newQuotationId = quotationSvc.create( quotationBean.obj );
				var quotationItemBean = helper.createQuotationItem( quotationId=newQuotationId );
				var newQuotationItemId = quotationItemSvc.create( quotationItemBean.obj );
				var quotationItemProductParentBean = helper.createQuotationItemProductParent( quotationItemId=newQuotationItemId );
				var newQuotationProductParentId = svc.create( quotationItemProductParentBean.obj );
				var bean = helper.createQuotationItemProduct( quotationItemId=newQuotationItemId, quotationItemProductParentId=newQuotationProductParentId, prodottoEscluso=quotationItemProductParentBean.obj.getProduct().getId() );
				var newId = svc.create( bean.obj );
				var result = svc.get( newId );

				expect( newId == result.getId() ).toBeTrue();
				expect( IsInstanceOf( result, "com.apirone.core.model.bean.QuotationItemProduct" ) ).toBeTrue();
				
                svc.delete( newId );
                svc.delete( newQuotationProductParentId );
				quotationItemSvc.delete( newQuotationItemId );
				quotationSvc.delete( newQuotationId );
			} );

			it( "Update quotation item product", function(){
                var random = new tests.utils.DBRandomData();
				var quotationBean = helper.createQuotation();
				var newQuotationId = quotationSvc.create( quotationBean.obj );
				var quotationItemBean = helper.createQuotationItem( quotationId=newQuotationId );
				var newQuotationItemId = quotationItemSvc.create( quotationItemBean.obj );
				var bean = helper.createQuotationItemProductParent( quotationItemId=newQuotationItemId );
				var obj = bean.obj;
                var oldProductId = obj.getProduct().getId();
				var newId = svc.create( obj );
                var newProductId = random.getRandomByTableName(limit=1, tableName='products').product_id.toString();

				obj.setProduct( productSvc.get( newProductId ) );
				obj.setId( newId );
				svc.update( obj );

				var result = svc.get( newId );

				expect( result.getId() == newId ).toBeTrue();
				expect( result.getProduct().getId() == newProductId ).toBeTrue();
				expect( result.getProduct().getId() != oldProductId ).toBeTrue();
				
                svc.delete( newId );
				quotationItemSvc.delete( newQuotationItemId );
				quotationSvc.delete( newQuotationId );
			} );

			it( "Delete quotation item product", function(){
				var quotationBean = helper.createQuotation();
				var newQuotationId = quotationSvc.create( quotationBean.obj );
				var quotationItemBean = helper.createQuotationItem( quotationId=newQuotationId );
				var newQuotationItemId = quotationItemSvc.create( quotationItemBean.obj );
				var bean = helper.createQuotationItemProductParent( quotationItemId=newQuotationItemId );
				var newId  = svc.create( bean.obj );
				
				var result = svc.delete( newId );
				result = quotationItemSvc.delete( newQuotationItemId );
				result = quotationSvc.delete( newQuotationId );
				
				expect( result.hasError() ).toBe( false );
			} );
		} );
	}

}
