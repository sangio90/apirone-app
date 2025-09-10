<cfoutput>

    <cfset attr = prc.printData.params>
    <!--- TODO: better than this --->
    <cfset productItemService = server["wirebox-apirone"].getInstance("ProductItemService")>
    <cfset componentService = server["wirebox-apirone"].getInstance("ComponentService")>

    <cfdocument format="pdf" fontembed="true" pagetype="A4" 
        overwrite="true"  >

        <style type="text/css">
            body, td, th, span, div { font-family: "Poppins"; font-size: 13px };
        </style>

        <!----
        <cfdocumentitem type="header">
            #getPrintHeader( prc.printData.title )#
        </cfdocumentitem>
        ---->

        <h2>#prc.printData.title#</h2>

        <cfloop array="#prc.printData.rows#" index="row">
            <cfset productItems = productItemService.getFlatTree( productId = row.id, includeMissingValues = false )>
            <div><h3>#row.category.name# - #row.line.name# #row.model.name# - #row.finish.name#</h3></div>
            <div>
                <cfloop array="#productItems#" item="productItem">
                    <div style="margin-bottom: 7px;">
                    <cfset components = componentService.list( productItemId=productItem.getId() )>

                    <i style="display:block;">#productItem.getAttribute().getName()# #productItem.getAttributeValue().getRawValue().getName()# (#components.len()#) </i>
                    
                    <cfloop array="#components#" item="component">
                        - #component.getQuantity()# #component.getRawProduct().getMeasurementUnit().getId()# x #component.getRawProduct().getName()# - #component.getColor().getName()# - #component.getVariant().getName()#<br/>
                    </cfloop>
                    </div>
                </cfloop>
            </div>            
        </cfloop>

        <!--- <table width="100%" border=0 style="border-collapse:collapse;" cellpadding="3"> 
            <!---
            <tr>
                <cfloop array="#prc.printData.columns#" item="item">
                    <td>#item.title#</td>
                </cfloop>
            </tr>
            ---->      
            <cfloop array="#prc.printData.rows#" index="row">

                <cfset productItems = productItemService.getFlatTree( productId = row.id, includeMissingValues = false )>

                <tr>
                    <td colspan="99"><h3>#row.category.name# - #row.line.name# #row.model.name# - #row.finish.name#</h3></td>
                </tr>
                <tr>
                    <td colspan="99">
                        <cfloop array="#productItems#" item="productItem">

                            <cfset components = componentService.list( productItemId=productItem.getId() )>

                            <i>#productItem.getAttribute().getName()# #productItem.getAttributeValue().getRawValue().getName()# (#components.len()#) </i><br/>

                            <cfloop array="#components#" item="component">
                                - #component.getRawProduct().getName()# - #component.getColor().getName()# - #component.getVariant().getName()#  x #component.getQuantity()#<br/>
                            </cfloop>
                            <br>

                        </cfloop>

                    </td>
                </tr>
            </cfloop>
        </table> --->
        
        <cfdocumentitem type="footer">
            #getPrintFooter()#
        </cfdocumentitem>
    
    </cfdocument>

</cfoutput>
