
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

            #productItemRowTmpl()#

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

<cffunction name="productItemRowTmpl">

    <cfsavecontent variable="render">
        <cfprocessingdirective pageEncoding="UTF-8">

        <cfoutput>
            <script type="text/x-kendo-template" id="product-item-row-tmpl">
                <tr class="k-master-row" data-uid="##: uid ##">
                    <td style="border-left: 4px solid ##=status.color.hex##">
                        <span data-bind="text: id"></span>
                    </td>
                    <td>
                        <span data-bind="html: spaces"></span>
                        <b data-bind="text: attribute.name" class="fs-10"></b>: 
                        <span data-bind="text: attributeValue.rawValue.name"></span>
                    </td>

                    <!--- attivo --->
                    ##if (status.id == 'ACT') {## 

                        <td class="text-center">
                            <button type="button" class="btn btn-default btn-sm" data-bind="click:openImagesList" data-type="productItem">
                                <i class="fas fa-image"></i> 
                            </button>
                        </td>

                        <td class="text-center">
                            <button type="button" class="btn btn-default btn-sm" data-bind="click:openAttributesList, attr: { data-origin-id: id }">
                                <i class="fas fa-plus"></i> 
                            </button>
                        </td>
                        <td class="text-center">
                            <button type="button" class="btn btn-default btn-sm" data-bind="click:openComponentsList" data-type="item"> 
                                <i class="fas fa-window-restore"></i>
                                <i class="button-badge info" data-bind="text: componentCount"></i> 
                            </button>
                        </td>
                        <td class="text-center">
                            <input type="checkbox" class="form-check-input"
                                name="selected"
                                value="##: id ##"
                            >
                        </td>

                    <!--- disattivo --->
                    ##} else {##

                        <td class="text-center">
                            <button type="button" class="btn btn-default btn-sm" data-bind="click:addValue">
                                <i class="fas fa-chevron-right"></i>
                            </button>
                        </td>
                    
                    ##}##
                </tr>
            </script>
            
        </cfoutput>

    </cfsavecontent>

    <cfreturn render>
</cffunction>
