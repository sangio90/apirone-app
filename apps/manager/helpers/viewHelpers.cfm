<cffunction name="template">
    <cfargument required="true" type="String" name="view">

    <cfreturn Replace( renderView( view="#arguments.view#" ), "nmscript", "script", "ALL" )>
</cffunction>

<cffunction name="breadcrumbs">
    <cfreturn "">
</cffunction>

<cffunction name="pageTitle">

    <cfsavecontent variable="local.html">
        <cfoutput>
            <div class="row mb-3 page-title">
                <div class="col-lg-8">
                    <cfif Len(prc.title)>
                        <h2>#prc.title#</h2>
                    </cfif>
                    
                    <cfif Len(prc.subtitle)>
                        <h4>#prc.subtitle#</h4>
                    </cfif>
                </div>
            </div>
        </cfoutput>
    </cfsavecontent>

    <cfreturn local.html>

</cffunction>

<cffunction name="includeJSFiles">

    <cfloop array="#prc.jsScripts#" index="thisScript">
        <cfoutput>
            <script src="/assets/#prc.staticVersion#/manager/js/#thisScript#.js"></script>
            <cfif  FileExists( ExpandPath( "/apps/manager/assets/js/tests/#thisScript#-test.js" ) ) && prc.isDev>
                <script src="/assets/#prc.staticVersion#/manager/js/tests/#thisScript#-test.js"></script>
            </cfif>
        </cfoutput>
    </cfloop>

</cffunction>


<cffunction name="productAttributesList" returntype="String">

    <cfargument name="type" type="String" required="true">
    
    <cfargument name="id" type="String" required="true" default="combination-grid-form">
    <cfargument name="class" type="String" default="no-pager">
    <cfargument name="source" type="String" default="items">
    <cfargument name="rowTemplate" type="String" default="combination/combination-item-row-tmpl">

    <cfset local.columns = "[
        { 'field':'Id', 'title':'ID', width: '60px' },
        { 'field':'name', 'title':'Attributo' },
        { 'field':'', 'title':'Aggiungi immagini', width: '55px'},
        { 'field':'', 'title':'Aggiungi altri attributi', width: '55px'},
        { 'field':'', 'title':'Aggiungi componenti all\'attributo', width: '55px'},
        { 
            'field'           :'', 
            'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
            'width'           :'40px',
            'headerAttributes': { 'class': 'text-center' }
        }
    ]">

    <cfset local.html = grid( 
        id          = arguments.id,
        class       = arguments.class,
        columns     = local.columns,
        source      = arguments.source,
        rowTemplate = arguments.rowTemplate
    )>

    <cfreturn local.html>
        
</cffunction>

<cffunction name="getPrintHeader">
    <cfreturn "<div><img src='/assets/main/img/logo.png' alt='Apir' style='width: 110px; height: 60px;'><div>">
</cffunction>

<cffunction name="importPrintStyle">
    <cfreturn ".no-print { display: none; visibility: hidden }; td, th, span, div { font-family: 'Arial'; font-size: 13px }">
</cffunction>

<cffunction name="getPrintFooter">

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

    <cfreturn local.html>

</cffunction>


<cffunction name="grid">

    <cfargument name="id" type="String" required="true">
    <cfargument name="rowTemplate" type="String" required="true">
    <cfargument name="sortable" type="String" required="true" default="false">
    <cfargument name="source" type="String" required="true" default="rows">
    <cfargument name="columns" type="String" required="true" default="[]">
    <cfargument name="pageSizes" type="String" required="true" default="['15', '50', '100' ]">
    <cfargument name="class" type="String" required="false" default="">

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
                window.addEventListener("load",function(event) {
                    $("###arguments.id# .k-table thead th").each(function(){

                        var ele = $(this);
                        var text = ele.text();

                        if( text.length ) {
                            ele.kendoTooltip({content: text})
                        }

                    })
                }, false);
            </script>
        </cfoutput>
    </cfsavecontent>

    <cfreturn local.html>

</cffunction>

<cfinclude template="buttonHelper.cfm">

<cfscript>
    
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

</cfscript>
