component extends="tests.utils.AbsSpec" {

	function run( testResults, testBox ){
		describe( "QuotationItemPositionService", function(){
			beforeEach( function(){
                quotationSvc = getContainer().getInstance( "QuotationService" );
                quotationItemSvc = getContainer().getInstance( "QuotationItemService" );
                quotationItemZoneSvc = getContainer().getInstance( "QuotationItemZoneService" );
                svc = getContainer().getInstance( "QuotationItemPositionService" );
                helper = super.getHelperData();
			} );

            it( "Create quotation item zone", function(){
				var quotationBean = helper.createQuotation();
				var newQuotationId = quotationSvc.create( quotationBean.obj );

				var quotationItemBean = helper.createQuotationItem( quotationId=newQuotationId );
				var newQuotationItemId = quotationItemSvc.create( quotationItemBean.obj );

				var quotationItemZoneBean = helper.createQuotationItemZoneParent( quotationItemId=newQuotationItemId );
				var newQuotationItemZoneId = quotationItemZoneSvc.create( quotationItemZoneBean.obj );

				var bean = helper.createQuotationItemPosition( quotationItemZoneId=newQuotationItemZoneId );
				var newId = svc.create( bean.obj );

				var result = svc.get( newId );

				expect( newId == result.getId() ).toBeTrue();
				expect( IsInstanceOf( result, "com.apirone.core.model.bean.QuotationItemPosition" ) ).toBeTrue();
				
                svc.delete( newId );
                quotationItemZoneSvc.delete( newquotationItemZoneId );
				quotationItemSvc.delete( newQuotationItemId );
				quotationSvc.delete( newQuotationId );
			} );

            
			it( "Update quotation item position", function(){
				var mock = new modules.cbMockData.models.MockData();
				var quotationBean = helper.createQuotation();
				var newQuotationId = quotationSvc.create( quotationBean.obj );

				var quotationItemBean = helper.createQuotationItem( quotationId=newQuotationId );
				var newQuotationItemId = quotationItemSvc.create( quotationItemBean.obj );

				var quotationItemZoneBean = helper.createQuotationItemZoneParent( quotationItemId=newQuotationItemId );
				var newQuotationItemZoneId = quotationItemZoneSvc.create( quotationItemZoneBean.obj );

				var bean = helper.createQuotationItemPosition( quotationItemZoneId=newQuotationItemZoneId );
				var obj = bean.obj;
				var newId = svc.create( obj );
                var oldPositionX = obj.getPositionCoordinateX();
                var oldPositionY = obj.getPositionCoordinateY();

				obj.setId( newId );

				var newQuotationItemZoneBean = helper.createQuotationItemZoneParent( quotationItemId=newQuotationItemId );
				var secondQuotationItemZoneId = quotationItemZoneSvc.create( newQuotationItemZoneBean.obj );

                obj.setQuotationItemZone( quotationItemZoneSvc.get(secondQuotationItemZoneId) );
				obj.setPositionCoordinateX( randRange(0, 99) & '.' & randRange(0, 99999) );
				obj.setPositionCoordinateY( randRange(0, 99) & '.' & randRange(0, 99999) );
				svc.update( obj );

				var result = svc.get( newId );

				expect( result.getId() == newId ).toBeTrue();
				expect( result.getQuotationItemZone().getId() != newQuotationItemZoneId ).toBeTrue();
				expect( result.getPositionCoordinateX() != oldPositionX ).toBeTrue();
				expect( result.getPositionCoordinateY() != oldPositionY ).toBeTrue();
				
                svc.delete( newId );
                quotationItemZoneSvc.delete( secondQuotationItemZoneId );
                quotationItemZoneSvc.delete( newQuotationItemZoneId );
				quotationItemSvc.delete( newQuotationItemId );
				quotationSvc.delete( newQuotationId );
			} );

			it( "Delete quotation item position", function(){
				var quotationBean = helper.createQuotation();
				var newQuotationId = quotationSvc.create( quotationBean.obj );

				var quotationItemBean = helper.createQuotationItem( quotationId=newQuotationId );
				var newQuotationItemId = quotationItemSvc.create( quotationItemBean.obj );
				
				var quotationItemZoneBean = helper.createQuotationItemZoneParent( quotationItemId=newQuotationItemId );
				var newQuotationItemZoneId = quotationItemZoneSvc.create( quotationItemZoneBean.obj );

				var bean = helper.createQuotationItemPosition( quotationItemZoneId=newQuotationItemZoneId );
				var newId = svc.create( bean.obj );
				
				var result = svc.delete( newId );
				result = quotationItemZoneSvc.delete( newQuotationItemZoneId );
				result = quotationItemSvc.delete( newQuotationItemId );
				result = quotationSvc.delete( newQuotationId );
				
				expect( result.hasError() ).toBe( false );
			} );

		} );
	}

}
