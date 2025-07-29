component extends="tests.utils.AbsSpec" {

	function run( testResults, testBox ){
		describe( "Quote", function(){
			beforeEach( function(){
				svc    = getModel().getInstance( "ProductService" );
				helper = super.getHelperData();
			} );

			it( "Create booking quote", function(){


				helper.createCompany();

				var bean = helper.createQuote()

				var newId = svc.create( bean.obj );

				var result = svc.get( newId );

				expect( newId == result.getId() ).toBeTrue();
				expect( IsInstanceOf( result, "com.iperchatbot.core.model.bean.Quote" ) ).toBeTrue();

				svc.delete( newId );
			} );

			it( "Update booking quote", function(){
				var bean = helper.createQuote()

				var obj = bean.obj;

				var newId = svc.create( bean.obj );

				var newSession  = Left( CreateUUID(), 8 ) & "-session";
				var newBoard    = Left( CreateUUID(), 4 ) & "-board";
				var newFrom     = helper.createDateFromNow();
				var newTo       = helper.createDateFromNow();
				var newChildren = RandRange( 1, 20 )
				var newAdults   = RandRange( 1, 20 )

				obj.setUserSession( newSession );
				obj.setBoard( newBoard );
				obj.setToDate( newTo );
				obj.setFromDate( newFrom );
				obj.setChildrenCount( newChildren );
				obj.setAdultsCount( newAdults );

				obj.setId( newId );
				svc.update( obj );

				var result = svc.get( newId );

				expect( result.getId() == newId ).toBeTrue();
				expect( result.getBoard() == newBoard ).toBeTrue();
				expect( result.getAdultsCount() == newAdults ).toBeTrue();
				expect( result.getChildrenCount() == newChildren ).toBeTrue();
				expect( result.getFromDate() == newFrom ).toBeTrue();
				expect( result.getToDate() == newTo ).toBeTrue();

				svc.delete( newId );
			} );

			it( "Delete booking quote", function(){
				var bean = helper.createQuote()

				var newId  = svc.create( bean.obj );
				var result = svc.delete( newId );

				expect( result.hasError() ).toBe( false );
			} );
		} );
	}

}
