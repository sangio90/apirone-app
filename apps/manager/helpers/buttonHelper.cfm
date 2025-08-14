<cfscript>

    function button( String bind, required String label="", required String class="" ){ 

        return getButton( argumentCollection = arguments );
    
    }

    function addButton( String bind, required String label="Carica" ){ 

        arguments["icon"] = "plus";

        return getButton( argumentCollection = arguments );
    
    }

    function printButton( String bind, required String label="Stampa", class="" ){ 

        arguments["icon"] = "print";

        return getButton( argumentCollection = arguments );
    
    }

    function searchButton( String bind, required String label="Cerca" ){ 

        arguments["icon"] = "search";

        return getButton( argumentCollection = arguments );
    
    }

    function saveButton( String bind, required String label="Salva" ){ 

        arguments["icon"] = "save";

        return getButton( argumentCollection = arguments );
    
    }

    function deleteButton( String bind, required String label="Cancella" ){ 

        arguments["icon"] = "trash";
        arguments["variant"] = "default";

        return getButton( argumentCollection = arguments );
    
    }

    function iconButton( String bind, required String icon, String variant="default", size="sm" ){ 

        arguments["label"] = "";
        
        return getButton( argumentCollection = arguments );
    
    }

    private function getButton( 
        required String label,
                 String bind="", 
                 String size="md", 
                 String type="submit", 
                 String variant="primary", 
                 String title="",
                 String icon="",
                 String class="" 
    ){ 

        ```
        <cfsavecontent variable="local.html">
            <cfoutput>
                <button type="#arguments.type#" class="btn btn-#arguments.variant# btn-#arguments.size# #arguments.class#" title="#arguments.title#"
                    #Len( arguments.bind ) ? 'data-bind="#arguments.bind#"' : ''#>
                    <i class="fas fa-#arguments.icon#"></i> #arguments.label#
                </button>
            </cfoutput>
        </cfsavecontent>
        ```
        
        return local.html;
    
    }

</cfscript>