<cfscript>
    function template( required String view ){ 
        return Replace( renderView( view="#arguments.view#" ), 'nmscript', 'script', 'ALL' );
    }

    function breadcrumbs( required String view ){ 
        return "";
    }

    function createMenu( required Array data=[], required String active="" ){ 

        var html = '';

        if ( !arguments.data.len() ) {
            arguments.data = DeserializeJSON( FileRead( ExpandPath('/config/data/menu.json.cfm') ) );
        }

        for ( var row in arguments.data ) {

            //se la chiave roles non c'è l'item è accessibile a tutti
            if ( !row.keyExists("roles") OR (ListFind( row.roles, 'ADM' ) ) ) {

                var parentClass = "";
                var activeClass = "";
                var expandedClass = "";
     
                if ( StructKeyExists ( row, "items" ) ) {
    
                    var parentClass = "nav-parent";
    
                    for ( var item in row.items ) {
                        if ( item.href == active ) {
                            expandedClass = "nav-expanded nav-active";
                        }
                    }
                
                }
                
                if ( arguments.active == row.href ) {
                    var activeClass = 'nav-active';
                }
                
                var element = '
                    <li class="#trim( parentClass & ' ' & activeClass & ' ' & expandedClass)#">
                        <a class="nav-link" href="#row.href#">
                            
                            # Len( row?.badge ) ? '<span class="float-end badge badge-primary">#row.badge#</span>' : '' #
                            
                            # Len( row?.icon ) ? '<i class="#row.icon#" aria-hidden="true"></i>' : '' #
                            
                            <span>#row.title#</span>
                        </a>
    
                        # parentClass.len() 
                            ? 
                                '<ul class="nav nav-children">' & 
                                    createMenu( row.items, arguments.active ) &
                                '</ul>'
                            : '' 
                        #
                    </li>
                ';
    
                html = html & element;                

            }
        
        }

        return html;

    }

    function getPrintHeader( title="" ){ 

        savecontent variable="html" {
            echo("
                <div>
                    <img src='/assets/main/img/logo.png' alt='Apir' style='width: 110px; height: 60px;'>
                </div>
            ");
        }

        return html;
    }
    
    function importPrintStyle(){ 

        return '
            .no-print { display: none; visibility: hidden }
            td, th, span, div { font-family: "Arial"; font-size: 13px }
        ';
    }

    function getPrintFooter(){ 

        ```
        <cfsavecontent variable="html">
            <cfoutput>
                <div style='border-top: 1px solid ##EAEAEA;'>
                <table width='100%' border=0 style='border-collapse:collapse'>
                    <tr>
                        <td style='padding-top:5px'>#cfdocument.currentpagenumber#/#cfdocument.totalpagecount#</td>
                        <td style='padding-top:5px' align='right'>#LsDateFormat( now(), 'dd/mm/yyyy' )#</td>
                    </tr>
                </table>
            </div>
        </cfoutput>
        
        </cfsavecontent>
        ```
        
        return html;
    }

    function grid( 
        required String id, 
        required String rowTemplate, 
        required String source="rows", 
        required String columns="[]" 
    ){ 

        ```
        <cfsavecontent variable="html">
            <cfoutput>
                <div 
                    id="#arguments.id#"
                    data-bound="NM.kendo.toggleScrollbar"
                    data-columns="#arguments.columns#" 
                    data-role="grid" 
                    data-sortable="true" 
                    data-bind="source: #arguments.source#"
                    data-pageable="true"
                    data-row-template="#ListLast( arguments.rowTemplate, "/" )#"
                    data-no-records="{ template : '<div style=\'width: 100%; text-align: center;\'><br>Nessun record trovato.<br><br></div>'}">
                </div>
                
                #template( view="jstemplate/#arguments.rowTemplate#" )#
            
            </cfoutput>
            
        </cfsavecontent>
        ```
        
        return html;
    }    
</cfscript>
