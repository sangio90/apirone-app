component extends="tests.utils.AbsSpec" {

	function run( testResults, testBox ){
		describe( "QuotationService", function(){
			beforeEach( function(){
				svc    = getContainer().getInstance( "QuotationService" );
				statusSvc    = getContainer().getInstance( "StatusService" );
                quotationSvc = getContainer().getInstance( "QuotationService" );
                quotationItemSvc = getContainer().getInstance( "QuotationItemService" );
                quotationItemProductSvc = getContainer().getInstance( "QuotationItemProductService" );
                quotationItemProductItemSvc = getContainer().getInstance( "QuotationItemProductItemService" );
                quotationItemZoneSvc = getContainer().getInstance( "QuotationItemZoneService" );
                quotationItemPositionSvc = getContainer().getInstance( "QuotationItemPositionService" );
				helper = super.getHelperData();
			} );

			it( "Create quotation", function(){
				var bean = helper.createQuotation();

				var newId = svc.create( bean.obj );
				var result = svc.get( newId );

				expect( newId == result.getId() ).toBeTrue();
				expect( IsInstanceOf( result, "com.apirone.core.model.bean.Quotation" ) ).toBeTrue();
				svc.delete( newId );
			} );

			it( "Create full quotation", function(){
                var random = new tests.utils.DBRandomData();
                var quotationBean = helper.createQuotation();
                var quotationId = quotationSvc.create( quotationBean.obj );
				var counter = 3;
				while ( counter > 0) {
					var quotationItemBean = helper.createQuotationItem( quotationId=quotationId );
					var quotationItemId = quotationItemSvc.create( quotationItemBean.obj );

					var quotationItemProductItemParentBean = helper.createQuotationItemProductItemParent( quotationItemId=quotationItemId );
					var quotationItemProductItemParentId = quotationItemProductItemSvc.create( quotationItemProductItemParentBean.obj );

					var quotationItemProductItemBean = helper.createQuotationItemProductItem( quotationItemId=quotationItemId, quotationItemProductItemParentId=quotationItemProductItemParentId, productItemEscluso=quotationItemProductItemParentBean.obj.getProductItem().getId() );
					var quotationItemProductItemId = quotationItemProductItemSvc.create( quotationItemProductItemBean.obj );

					var quotationItemZoneParentBean = helper.createQuotationItemZoneParent( quotationItemId=quotationItemId );
					var quotationZoneParentId = quotationItemZoneSvc.create( quotationItemZoneParentBean.obj );

					var quotationItemZoneBean = helper.createQuotationItemZone( quotationItemId=quotationItemId, quotationItemZoneParentId=quotationZoneParentId );
					var quotationItemZoneId = quotationItemZoneSvc.create( quotationItemZoneBean.obj );

					var quotationItemPositionBean = helper.createQuotationItemPosition( quotationItemZoneId=quotationItemZoneId );
					var quotationItemPositionId = quotationItemPositionSvc.create( quotationItemPositionBean.obj );
					
					var result = quotationItemPositionSvc.get( quotationItemPositionId );
					counter--;
				}

				expect( quotationItemPositionId == result.getId() ).toBeTrue();
				expect( IsInstanceOf( result, "com.apirone.core.model.bean.QuotationItemPosition" ) ).toBeTrue();
				
                //quotationItemPositionSvc.delete( quotationItemPositionId );
                //quotationItemZoneSvc.delete( quotationItemZoneId );
                //quotationItemZoneSvc.delete( quotationZoneParentId );
                //quotationItemProductItemSvc.delete( quotationItemProductItemId );
                //quotationItemProductItemSvc.delete( quotationItemProductItemParentId );
                //quotationItemProductSvc.delete( quotationItemProductId );
                //quotationItemProductSvc.delete( quotationItemProductParentId );
                //quotationItemSvc.delete( quotationItemId );
                //quotationSvc.delete( quotationId );
			} );

			it( "Update quotation", function(){
				var bean = helper.createQuotation();
				var obj = bean.obj;
				var newId = svc.create( obj );

				var newDescription = "testDescription" & RandRange( 1000, 9999 );

				obj.setDescription( newDescription );
				obj.setId( newId );
				svc.update( obj );

				var result = svc.get( newId );

				expect( result.getId() == newId ).toBeTrue();
				expect( result.getDescription() == newDescription ).toBeTrue();

				svc.delete( newId );
			} );

			it( "Update quotation status", function(){
                transaction {
					var random = new tests.utils.DBRandomData();
					var quotationId = random.getRandomByTableName(limit=1, tableName='quotations').quotation_id.toString();
					var quotationBean = quotationSvc.get( quotationId );

					var statuses = random.getStatuses(limit=6, entity='QUOTATION');
					for (status in statuses) {
						if (status.status_id EQ quotationBean.getStatus().getId()) {
							continue;
						}
						var newStatus = status;
						break;
					}
					var result = svc.clone( quotation=quotationBean, status=newStatus.status_id );

					var originalQuotation = quotationBean;
					var clonedQuotation = svc.get(result);
					var originalItems = quotationItemSvc.list(quotationId=originalQuotation.getId());
					var clonedItems = quotationItemSvc.list(quotationId=clonedQuotation.getId());
					expect( arrayLen(originalItems) ).toBe( arrayLen(clonedItems) );
					for (var i=1; i <= arrayLen(originalItems); i++) {
						var origProducts = quotationItemProductSvc.list(quotationItemId=originalItems[i].getId());
						var cloneProducts = quotationItemProductSvc.list(quotationItemId=clonedItems[i].getId());
						expect( arrayLen(origProducts) ).toBe( arrayLen(cloneProducts) );
					}
					transaction action="rollback";
				}
			} );

			it( "Delete quotation", function(){
				var bean = helper.createQuotation();
				var newId  = svc.create( bean.obj );
				var result = svc.delete( newId );
                
				expect( result.hasError() ).toBe( false );
			} );
		} );
	}

}
