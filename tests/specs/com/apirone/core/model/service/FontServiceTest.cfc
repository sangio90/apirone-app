component extends="tests.utils.AbsSpec" {

	function run( testResults, testBox ){
		describe( "FontService", function(){
			beforeEach( function(){
				svc    = getContainer().getInstance( "FontService" );
				helper = super.getHelperData();
			} );

			it( "Create font", function(){
				var bean = helper.createFont();

				var newId = svc.create( bean.obj );
				var result = svc.get( newId );

				expect( newId == result.getId() ).toBeTrue();
				expect( IsInstanceOf( result, "com.apirone.core.model.bean.Font" ) ).toBeTrue();
				svc.delete( newId );
			} );

		} );
	}

}
