component extends="tests.utils.AbsSpec" {

	function run( testResults, testBox ){
		describe( "QuotationItemZoneService", function(){
			beforeEach( function(){
                quotationSvc = getContainer().getInstance( "QuotationService" );
				quotationItemSvc = getContainer().getInstance( "QuotationItemService" );
				svc = getContainer().getInstance( "QuotationItemZoneService" );
				helper = super.getHelperData();
			} );

			it( "Create quotation item zone", function(){
				var quotationBean = helper.createQuotation();
				var newQuotationId = quotationSvc.create( quotationBean.obj );

				var quotationItemBean = helper.createQuotationItem( quotationId=newQuotationId );
				var newQuotationItemId = quotationItemSvc.create( quotationItemBean.obj );

				var bean = helper.createQuotationItemZoneParent( quotationItemId=newQuotationItemId );
				var newId = svc.create( bean.obj );

				var result = svc.get( newId );

				expect( newId == result.getId() ).toBeTrue();
				expect( IsInstanceOf( result, "com.apirone.core.model.bean.QuotationItemZone" ) ).toBeTrue();
				
                svc.delete( newId );
				quotationItemSvc.delete( newQuotationItemId );
				quotationSvc.delete( newQuotationId );
			} );

			it( "Create quotation item zone with parent", function(){
				var quotationBean = helper.createQuotation();
				var newQuotationId = quotationSvc.create( quotationBean.obj );

				var quotationItemBean = helper.createQuotationItem( quotationId=newQuotationId );
				var newQuotationItemId = quotationItemSvc.create( quotationItemBean.obj );

				var quotationItemZoneParentBean = helper.createQuotationItemZoneParent( quotationItemId=newQuotationItemId );
				var newQuotationZoneParentId = svc.create( quotationItemZoneParentBean.obj );

				var bean = helper.createQuotationItemZone( quotationItemId=newQuotationItemId, quotationItemZoneParentId=newQuotationZoneParentId );
				var newId = svc.create( bean.obj );

				var result = svc.get( newId );

				expect( newId == result.getId() ).toBeTrue();
				expect( IsInstanceOf( result, "com.apirone.core.model.bean.QuotationItemZone" ) ).toBeTrue();
				
                svc.delete( newId );
                svc.delete( newQuotationZoneParentId );
				quotationItemSvc.delete( newQuotationItemId );
				quotationSvc.delete( newQuotationId );
			} );

			it( "Update quotation item zone", function(){
				var mock = new modules.cbMockData.models.MockData();
				var quotationBean = helper.createQuotation();
				var newQuotationId = quotationSvc.create( quotationBean.obj );

				var quotationItemBean = helper.createQuotationItem( quotationId=newQuotationId );
				var newQuotationItemId = quotationItemSvc.create( quotationItemBean.obj );

				var bean = helper.createQuotationItemZoneParent( quotationItemId=newQuotationItemId );
				var obj = bean.obj;
				var newId = svc.create( obj );

				var newZone = "suite junior";

				obj.setId( newId );
				obj.setName( newZone );
				svc.update( obj );

				var result = svc.get( newId );

				expect( result.getId() == newId ).toBeTrue();
				expect( result.getName() == 'suite junior' ).toBeTrue();
				
                svc.delete( newId );
				quotationItemSvc.delete( newQuotationItemId );
				quotationSvc.delete( newQuotationId );
			} );

			it( "Delete quotation item zone", function(){
				var quotationBean = helper.createQuotation();
				var newQuotationId = quotationSvc.create( quotationBean.obj );
				var quotationItemBean = helper.createQuotationItem( quotationId=newQuotationId );
				var newQuotationItemId = quotationItemSvc.create( quotationItemBean.obj );
				var bean = helper.createQuotationItemZoneParent( quotationItemId=newQuotationItemId );
				var newId  = svc.create( bean.obj );
				
				var result = svc.delete( newId );
				result = quotationItemSvc.delete( newQuotationItemId );
				result = quotationSvc.delete( newQuotationId );
				
				expect( result.hasError() ).toBe( false );
			} );
		} );
	}

}
