<cfscript>
    function template( required String view ){ 
        return Replace( renderView( view="#arguments.view#" ), "nmscript", "script", "ALL" );
    }

    function breadcrumbs( required String view ){ 
        return "";
    }

    function pageTitle(){ 

        ```
        <cfsavecontent variable="local.html">
            <cfoutput>
                <div class="row mb-3 page-title">
                    <div class="col-lg-8">
                        <h2>#prc.title#</h2>
                        <cfif Len(prc.subtitle)><h4>#prc.subtitle#</h4></cfif>
                    </div>
                </div>
            </cfoutput>
        </cfsavecontent>
        ```
        
        return local.html;
    
    }

    function includeJSFiles(){ 

        for ( var thisScript in prc.jsScripts ) {

            echo("<script src=""/assets/#prc.staticVersion#/manager/js/#thisScript#.js""></script>");
            
            if ( FileExists( ExpandPath( "/apps/manager/assets/js/tests/#thisScript#-test.js" ) ) && prc.isDev ) {
                echo("<script src=""/assets/#prc.staticVersion#/manager/js/tests/#thisScript#-test.js""></script>");
            }
        }
        
    }

    function createMenu( required Array data=[], required String active="" ){ 

        var html = "";

        if ( !arguments.data.len() ) {
            arguments.data = DeserializeJSON( FileRead( ExpandPath("/config/data/menu.json.cfm") ) );
        }

        for ( var row in arguments.data ) {

            //se la chiave roles non c'è l'item è accessibile a tutti
            if ( !row.keyExists("roles") OR (ListFind( row.roles, "ADM" ) ) ) {

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
                    <li class="#trim( parentClass & ' ' & activeClass & ' ' & expandedClass )#">
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
        <cfsavecontent variable="local.html">
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
        
        return local.html;
    }

    function grid( 
        required String id, 
        required String rowTemplate, 
        required String sortable=false, 
        required String source="rows", 
        required String columns="[]",
        required String pageSizes="['15', '50', '100' ]",
                 String class=""
    ){ 

        ```
        <cfsavecontent variable="local.html">
            <cfoutput>
                <div 
                    id="#arguments.id#"
                    class="#arguments.class#"
                    data-bound="NM.kendo.toggleScrollbar"
                    data-columns="#arguments.columns#" 
                    data-role="grid" 
                    data-sortable="#arguments.sortable#" 
                    data-reorderable=""
                    data-bind="source: #arguments.source#"
                    data-pageable="{ 'pageSizes': #arguments.pageSizes# }"
                    data-row-template="#ListLast( arguments.rowTemplate, "/" )#"
                    data-no-records="{ template : '<div class=grid-no-data><br>Nessun record trovato.<br><br></div>'}">
                </div>
                <div class="white-small">jstemplate/#arguments.rowTemplate#</div>

                #template( view="jstemplate/#arguments.rowTemplate#" )#

                <script>
                    window.onload= function() {
                        $("###arguments.id# .k-table thead th").each(function(){
                            var ele = $(this);
                            var text = ele.text();

                            if( text.length ) {
                                ele.kendoTooltip({content: text})
                            }

                        })
                    }
                </script>
            </cfoutput>
        </cfsavecontent>
        ```
        
        return local.html;
    }    

    include "buttonHelper.cfm";

</cfscript>
