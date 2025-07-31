component extends="tests.utils.AbsSpec" {

	function run( testResults, testBox ){
		describe( "QuotationItemService", function(){
			beforeEach( function(){
				var svc    = getModel().getInstance( "QuotationItemService" );
				var helper = super.getHelperData();
			} );

			it( "Create quotation item", function(){
				var bean = helper.createQuotationItem();
				var newId = svc.create( bean.obj );
				var result = svc.get( newId );
				
				expect( newId == result.getId() ).toBeTrue();
				expect( IsInstanceOf( result, "com.apirone.core.model.bean.QuotationItem" ) ).toBeTrue();
				
				svc.delete( newId );
			} );

			it( "Update quotation item", function(){
				var bean = helper.createQuotationItem();
				var obj = bean.obj;
				var newId = svc.create( obj );
				var newPrice = val(randRange(1, 20) & '.' & randRange(0, 10));
				
				obj.setPrice( newPrice );
				obj.setId( newId );
				svc.update( obj );
				
				var result = svc.get( newId );
				
				expect( result.getId() == newId ).toBeTrue();
				expect( result.getPrice() == newPrice ).toBeTrue();
				
				svc.delete( newId );
			} );

			it( "Delete quotation item", function(){
				var bean = helper.createQuotationItem();
				var newId  = svc.create( bean.obj );
				var result = svc.delete( newId );
				
				expect( result.hasError() ).toBe( false );
			} );
		} );
	}

}
