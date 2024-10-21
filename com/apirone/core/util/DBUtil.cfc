/**
 * @author Roberto Marzialetti <roberto@marzialetti.com>
 * @since 18/10/2024
 */

 component output="false" accessors="true" {

    public String function getDBField( required String field ) {

        var fields = DESerializeJSON( FileRead( ExpandPath("/config/DBFields.json.cfm") ) );
 
        if ( !structKeyExists( fields, arguments.field ) ) {

            throw( 
                message="Field [#arguments.field#] not found in available values.",
                type="apirone.errors.AbsService.DBFieldNotFound" 
            );

        }

        return LCase( fields[ arguments.field ] );
    }

}