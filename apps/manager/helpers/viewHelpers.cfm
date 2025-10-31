<cffunction name="template">
    <cfargument required="true" type="String" name="view">

    <cfreturn Replace( renderView( view="#arguments.view#" ), "nmscript", "script", "ALL" )>
</cffunction>

<cffunction name="relevantPath">
    <cfargument required="true" type="String" name="fullPath">

    <cfset var parts = ListToArray(fullPath, server.system.properties["file.separator"])>
    <cfset var fileName = Replace( parts[arrayLen(parts)], ".cfm", "", "ALL")>
    <cfset var lastDir = parts[arrayLen(parts)-1]>

    <cfreturn "#lastDir#/#fileName#">

</cffunction>

<cffunction name="breadcrumbs">
    <cfreturn "">
</cffunction>

<cffunction name="pageTitle">

    <cfsavecontent variable="local.html">
        <cfoutput>
            <div class="row mb-3 page-title">
                <div class="col-12">
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

<!---
    methods for printing 
--->

<cffunction name="productAttributesList" returntype="String">

    <cfargument name="type" type="String" required="true">
    
    <cfargument name="id" type="String" required="true" default="product-items-grid">
    <cfargument name="class" type="String" default="no-pager">
    <cfargument name="source" type="String" default="items">
    <cfargument name="rowTemplate" type="String" default="product/product-item-row-tmpl">
    <cfargument name="onDataBound" type="String" required="false" default="NM.kendo.toggleScrollbar">
    <cfargument name="pageSizes" type="String" required="false" default="[ '15', '50', '100' ]">

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
        pageSizes   = arguments.pageSizes,
        rowTemplate = arguments.rowTemplate,
        onDataBound = arguments.onDataBound
    )>

    <cfreturn local.html>
        
</cffunction>

<cffunction name="grid">

    <cfargument name="id" type="String" required="true">
    <cfargument name="rowTemplate" type="String" required="true">
    <cfargument name="sortable" type="String" required="true" default="false">
    <cfargument name="source" type="String" required="true" default="rows">
    <cfargument name="columns" type="String" required="true" default="[]">
    <cfargument name="pageSizes" type="String" required="true" default="[ '15', '50', '100' ]"> <!--- "false" for mute paging --->
    <cfargument name="class" type="String" required="false" default="">
    <cfargument name="onDataBound" type="String" required="false" default="NM.kendo.toggleScrollbar">

    <cfsavecontent variable="local.html">
        <cfoutput>
            <div 
                id="#arguments.id#"
                class="#arguments.class#"
                data-bound="#arguments.onDataBound#"
                data-columns="#arguments.columns#" 
                data-role="grid" 
                data-sortable="#arguments.sortable#" 
                data-reorderable=""
                data-bind="source: #arguments.source#"
                <cfif arguments.pageSizes NEQ "false">
                    data-pageable="{ 'pageSizes': #arguments.pageSizes# }"
                </cfif>
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

<cffunction name="table">

    <cfargument name="id" type="String" required="true" default="table-#CreateUUID()#">
    <cfargument name="rowTemplate" type="String" required="true">
    <cfargument name="source" type="String" default="rows">
    <cfargument name="columns" type="String" default="">
    <cfargument name="class" type="String" default="">

    <cfset var thisColumns = []>

    <cfif IsJSON( columns ) >
        <cfset thisColumns = DESerializeJSON( columns )>
    </cfif>

    <cfsavecontent variable="local.html">
        <cfoutput>

            <table class="table table-hover #arguments.class# mb-0" id="#arguments.id#">

                <cfif len(thisColumns)>
                    <thead>
                        <tr>
                            <cfloop array="#thisColumns#" index="local.col">
                                <cfif !local.col.keyExists("width")>
                                    <cfset local.col.width = "">
                                </cfif>
                                <cfif !local.col.keyExists("title")>
                                    <cfset local.col.title = "">
                                </cfif>
                                <th style="width:#local.col.width#">#local.col.title#</th>
                            </cfloop>
                        </tr>
                    </thead>
                </cfif>

                <tbody data-bind="source:#arguments.source#" data-template="#ListLast( arguments.rowTemplate, "/" )#">
                </tbody>
            </table>
            
            <div class="white-small mb-1">jstemplate/#arguments.rowTemplate#</div>

            #template( view="jstemplate/#arguments.rowTemplate#" )#

        </cfoutput>
    </cfsavecontent>

    <cfreturn local.html>

</cffunction>

<cfinclude template="buttonHelper.cfm">

<cfscript>
    
    function createMenu( required Array data=[], required String active="" ){ 

        var html = "";

        for ( var row in arguments.data ) {

            var originClass = "";
            var activeClass = "";
            var expandedClass = "";
    
            if ( StructKeyExists ( row, "items" ) ) {

                var originClass = "nav-parent";

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
                <li class="#trim( originClass & ' ' & activeClass & ' ' & expandedClass )#">
                    <a class="nav-link" href="#row.href#">
                        
                        # Len( row?.badge ) ? '<span class="float-end badge badge-primary">#row.badge#</span>' : '' #
                        
                        # Len( row?.icon ) ? '<i class="#row.icon#" aria-hidden="true"></i>' : '' #
                        
                        <span>#row.title#</span>
                    </a>

                    # originClass.len() 
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

        return html;

    }

</cfscript>
