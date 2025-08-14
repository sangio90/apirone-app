/**
 * AbsDecorator class
 * @author Roberto Marzialetti <roberto@marzialetti.com>
 * @since 09/08/2025
 */

component output="false" accessors="true" {

	private Struct function logEvent(){
		var helper = getContainer().getInstance( "AuditHelper" );
		helper.logEvent( argumentCollection = arguments );
	}

	private Struct function getLogger(){
		var bean = getContainer().getInstance( "Logger" );

		return bean;
	}

	private Struct function getContainer(){
		return server[ "wireBox-apirone" ];
	}

}
