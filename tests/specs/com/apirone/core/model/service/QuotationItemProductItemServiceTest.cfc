component extends="tests.utils.AbsSpec" {

	function run( testResults, testBox ){
		describe( "QuotationItemProductItemService", function(){
			beforeEach( function(){
                quotationSvc = getContainer().getInstance( "QuotationService" );
                quotationItemSvc = getContainer().getInstance( "QuotationItemService" );
                quotationItemProductSvc = getContainer().getInstance( "QuotationItemProductService" );
                svc = getContainer().getInstance( "QuotationItemProductItemService" );
                productSvc = getContainer().getInstance( "ProductService" );
                productItemSvc = getContainer().getInstance( "ProductItemService" );
                helper = super.getHelperData();
			} );

			it( "Create quotation item product item", function(){
                var random = new tests.utils.DBRandomData();
                var quotationBean = helper.createQuotation();
                var newQuotationId = quotationSvc.create( quotationBean.obj );

                var quotationItemBean = helper.createQuotationItem( quotationId=newQuotationId );
                var newQuotationItemId = quotationItemSvc.create( quotationItemBean.obj );

                var quotationItemProductBean = helper.createQuotationItemProductParent( quotationItemId=newQuotationItemId );
                var newQuotationItemProductId = quotationItemProductSvc.create( quotationItemProductBean.obj );

				var bean = helper.createQuotationItemProductItemParent( quotationItemProductId=newQuotationItemProductId );
                var newId = svc.create( bean.obj );
                var result = svc.get( newId );

                expect( newId == result.getId() ).toBeTrue();
                expect( IsInstanceOf( result, "com.apirone.core.model.bean.QuotationItemProductItem" ) ).toBeTrue();

                svc.delete( newId );
                quotationItemProductSvc.delete( newQuotationItemProductId );
                quotationItemSvc.delete( newQuotationItemId );
                quotationSvc.delete( newQuotationId );
			} );

            it( "Update quotation item product item", function(){
                var random = new tests.utils.DBRandomData();
                var quotationBean = helper.createQuotation();
                var newQuotationId = quotationSvc.create( quotationBean.obj );

                var quotationItemBean = helper.createQuotationItem( quotationId=newQuotationId );
                var newQuotationItemId = quotationItemSvc.create( quotationItemBean.obj );

                var quotationItemProductBean = helper.createQuotationItemProductParent( quotationItemId=newQuotationItemId );
                var newQuotationItemProductId = quotationItemProductSvc.create( quotationItemProductBean.obj );

                var productItemId = random.getRandomByTableName(limit=1, tableName='product_items').product_item_id.toString();
                var bean = helper.createQuotationItemProductItemParent( quotationItemProductId=newQuotationItemProductId );
                var obj = bean.obj;
                var newId = svc.create( obj );
                var result = svc.get( newId );

                var newProductItemId = random.getRandomByTableName(limit=1, tableName='product_items').product_item_id.toString();
                result.setProductItem( productItemSvc.get( newProductItemId ) );
                svc.update( result );
                var updated = svc.get( newId );

                expect( updated.getProductItem().getId() == newProductItemId ).toBeTrue();

                svc.delete( newId );
                quotationItemProductSvc.delete( newQuotationItemProductId );
                quotationItemSvc.delete( newQuotationItemId );
                quotationSvc.delete( newQuotationId );
            } );

            it( "Delete quotation item product item", function(){
                var quotationBean = helper.createQuotation();
                var newQuotationId = quotationSvc.create( quotationBean.obj );

                var quotationItemBean = helper.createQuotationItem( quotationId=newQuotationId );
                var newQuotationItemId = quotationItemSvc.create( quotationItemBean.obj );

                var quotationItemProductBean = helper.createQuotationItemProductParent( quotationItemId=newQuotationItemId );
                var newQuotationItemProductId = quotationItemProductSvc.create( quotationItemProductBean.obj );

				var bean = helper.createQuotationItemProductItemParent( quotationItemProductId=newQuotationItemProductId );
                var newId = svc.create( bean.obj );

                var result = svc.delete( newId );
                result = quotationItemProductSvc.delete( newQuotationItemProductId );
                result = quotationItemSvc.delete( newQuotationItemId );
                result = quotationSvc.delete( newQuotationId );

                expect( result.hasError() ).toBe( false );
            } );

		} );
	}

}
