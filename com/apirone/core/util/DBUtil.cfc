/**
 * @author Roberto Marzialetti <roberto@marzialetti.com>
 * @since 18/10/2024
 */

 component output="false" accessors="true" {

    public Struct function getDBField( required String field ) {

        var fields = DESerializeJSON( FileRead( ExpandPath("/config/DBFields.json.cfm") ) );
 
        if ( !structKeyExists( fields, arguments.field ) ) {

            throw( 
                message="Field [#arguments.field#] not found in available values.",
                type="apirone.errors.AbsService.DBFieldNotFound" 
            );

        }

        return fields[ arguments.field ];
    }

    public String function getCompleteSQL( required String sql, required Array params=[] ) {

        var result = arguments.sql;

        var i = 1;
        for( var item in arguments.params ) {
            result = Replace( result, "?", "'#item#'", i );
            i++;
        }

        return result;
            
    }

}

