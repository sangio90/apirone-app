component extends="tests.utils.AbsSpec" {

	function run( testResults, testBox ){
		describe( "ProfileService", function(){
			beforeEach( function(){
				svc    = getContainer().getInstance( "ProfileService" );
				helper = super.getHelperData();
			} );

			it( "Create profile", function(){
				var bean = helper.createProfile();

				var newId = svc.create( bean.obj );
				var result = svc.get( newId );
                
				expect( newId == result.getId() ).toBeTrue();
				expect( IsInstanceOf( result, "com.apirone.core.model.bean.Profile" ) ).toBeTrue();
				svc.delete( newId );
			} );

			it( "Update profile", function(){
				var bean = helper.createProfile();
				var obj = bean.obj;
				var newId = svc.create( obj );

				var newFirstName = "TestFirst" & RandRange( 1000, 9999 );
				var newLastName = "TestLast" & RandRange( 1000, 9999 );
				var newEmail = "test" & RandRange( 1000, 9999 ) & "@example.com";

				obj.setFirstName( newFirstName );
				obj.setLastName( newLastName );
				obj.setEmail( newEmail );
				obj.setId( newId );
				svc.update( obj );

				var result = svc.get( newId );

				expect( result.getId() == newId ).toBeTrue();
				expect( result.getFirstName() == newFirstName ).toBeTrue();
				expect( result.getLastName() == newLastName ).toBeTrue();
				expect( result.getEmail() == newEmail ).toBeTrue();

				svc.delete( newId );
			} );

			it( "Delete profile", function(){
				var bean = helper.createProfile();
				var newId  = svc.create( bean.obj );
				var result = svc.delete( newId );
                
				expect( result.hasError() ).toBe( false );
			} );
		} );
	}

}
