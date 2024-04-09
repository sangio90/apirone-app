<cfscript>
    function getMenu(){ 

        var data = DESerializeJSON( FileRead( '/config/data/publicMenu.json.cfm' ) );

        return data;
    }
</cfscript>
