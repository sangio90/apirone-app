component extends="com.apirone.core.controller.AbsController" {

	function dashboard( event, rc, prc ){
		prc.title = "Dashboard";

		var user = prc.user;
		prc.isCommAdmin = !isNull( user ) && !isNull( user.getRole() ) && user.getRole().getId() == 'CMA';

		if ( prc.isCommAdmin ) {
			var pendingResult = super.fire( "Quotation.search", { statusId: 'PEN', limit: 1 } );
			prc.pendingApprovalCount = pendingResult.getTotal();
		}

		event.setView( "main/dashboard" );
	}

	function tmp( event, rc, prc ){
		prc.title = "Tmp";


		view( "/apps/manager/views/util/tmp" );
		abort;


		//event.setView( "util/tmp" );
	}

	/*
		some test for Coldbox Router group()
		not works :-(
	*/
	function postMethod( event, rc, prc ){
		dump( "Post" );

		dump( rc.keyExists( "permissions" ) );
		dump( prc.keyExists( "permissions" ) );
		dump( rc.keyExists( "middleware" ) );
		dump( prc.keyExists( "middleware" ) );
		dump( rc.keyExists( "namespace" ) );
		dump( prc.keyExists( "namespace" ) );
		abort;
	}

	function getMethod( event, rc, prc ){
		dump( "Get" );

		dump( rc.keyExists( "permissions" ) );
		dump( prc.keyExists( "permissions" ) );
		dump( rc.keyExists( "middleware" ) );
		dump( prc.keyExists( "middleware" ) );
		dump( rc.keyExists( "namespace" ) );
		dump( prc.keyExists( "namespace" ) );
		abort;
	}

}
