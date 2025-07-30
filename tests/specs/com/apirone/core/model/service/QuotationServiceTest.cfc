component extends="tests.utils.AbsSpec" {

	function run( testResults, testBox ){
		describe( "QuotationService", function(){
			beforeEach( function(){
				svc    = getModel().getInstance( "QuotationService" );
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

			it( "Delete quotation", function(){
				var bean = helper.createQuotation();
				var newId  = svc.create( bean.obj );
				var result = svc.delete( newId );
                
				expect( result.hasError() ).toBe( false );
			} );
		} );
	}

}
