component{

	function configure(){

		//var settings = new config.Settings();
		
		setFullRewrites( true );

		get( "/healthcheck", function( event, rc, prc ) {
			return "#now()# Ok!";		
		} );

		get(
			"/home"
		).to('MainController.home').end();

		get(
			"/contacts"
		).to('MainController.contacts').end();
		
		get(
			"/for-companies"
		).to('MainController.forCompanies').end();

		get(
			"/for-partners"
		).to('MainController.forPartners').end();

		post(
			"/ajax/send-message"
		).to('UtilAjaxController.sendMessage').end();

		get(
			"/employee/check"
		).to('EmployeeController.check').end();

		post(
			"/employee/check-fiscalcode"
		).to('EmployeeController.checkFiscalCode').end();

		post(
			"/employee/create"
		).to('EmployeeController.create').end();		

		get(
			"/employee/subscribe"
		).to('EmployeeController.subscribe').end();

		get(
			"/employee/card-assign/:employeeId"
		).to('EmployeeController.card').end();

		post(
			"/employee/card-assign/:employeeId/do"
		).to('EmployeeController.assignCard').end();

		get(
			"/lookup/(.*)/datajs" //[TODO] "JSDATA" non funziona
		).to('LookupController.datajs').end();

	}

}
