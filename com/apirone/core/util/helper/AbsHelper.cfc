/**
 * AbsHelper.cfc
 * @author Roberto Marzialetti <roberto@marzialetti.com>
 * @since 14/08/2025a
 */

component {

	private Struct function getContainer(){
		return server[ "wireBox-apirone" ];
	}

}
