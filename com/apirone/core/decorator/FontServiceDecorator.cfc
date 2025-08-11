component extends="com.apirone.core.decorator.AbsDecorator" accessors="true" {

	property name="fontServiceBase" inject="FontServiceBase";
	property name="logger" inject="Logger"; // Un tuo logger, anche semplice

	function get( id ){
		logger.info( "Calling FontService.get with ID: #id#" );
		return fontServiceBase.get( id );
	}

	function delete( id ){
		logAction.info( "Calling FontService.delete with ID: #id#" );
		return fontServiceBase.delete( id );
	}

	function search(){
		super.logAction( type="font.search", message="Before: FontService.search with args: #SerializeJSON( arguments )#" );
		
		var reesult = fontServiceBase.search( argumentCollection = arguments );
		
		super.logAction( type="font.search", message="After: FontService.search with args: #SerializeJSON( arguments )#" );
		
		return reesult;
	}

}
