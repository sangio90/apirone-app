component{

	function configure(){

		setFullRewrites( true );

		get( "/healthcheck", function( event, rc, prc ) {
			return "#now()# Ok!";		
		} );

		get(
			"/home"
		).to('MainController.home').end();

	}

}
