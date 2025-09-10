<cfoutput>

    <!--- TODO: better than this --->
    <cfset productItemService = server["wirebox-apirone"].getInstance("ProductItemService")>
    <cfset componentService = server["wirebox-apirone"].getInstance("ComponentService")>

    <cfdocument attributeCollection="#args.pdfArgs#">

        #importPrintStyle()#

        <h2>#args.title#</h2>

        <h3>Dell'articolo</h3>

        <cfloop array="#args.rows#" index="row">
        </cfloop>

        <h3>Degli attributi</h3>

        <cfloop array="#args.rows#" index="row">
            <cfset productItems = productItemService.getFlatTree( productId = row.id, includeMissingValues = false )>
            <div><h3>#row.category.name# - #row.line.name# #row.model.name# - #row.finish.name#</h3></div>
            <div>
                <cfloop array="#productItems#" item="productItem">
                    <div style="margin-bottom: 7px;">
                    <cfset components = componentService.list( productItemId=productItem.getId(), includeBaseAttributeComponents=true )>

                    <i style="display:block;">#productItem.getAttribute().getName()# #productItem.getAttributeValue().getRawValue().getName()# (#components.len()#) </i>
                    
                    <cfloop array="#components#" item="component">
                        - <b>#component.getQuantity()# 

                            <cfif component.getTypeId() == "base">
                                + #component.getOverride().getQuantity()# = #component.getTotalQuantity()#
                            </cfif>
                            
                            #component.getRawProduct().getMeasurementUnit().getId()#</b> x #component.getRawProduct().getName()# 
                            - #component.getColor().getName()# 
                            - #component.getVariant().getName()#<br/>
                    </cfloop>
                    </div>
                </cfloop>
            </div>            
        </cfloop>
        
        <cfdocumentitem type="footer">
            #getPrintFooter()#
        </cfdocumentitem>
    
    </cfdocument>

</cfoutput>
