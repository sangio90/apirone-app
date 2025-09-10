<cfoutput>

    <cfdocument attributeCollection="#args.pdfArgs#">

        #importPrintStyle()#

        <h2>#args.title#</h2>

        <div>
            <cfloop collection="#args.filters#" item="value" index="key">
                Filtri: <b>#key#:</b> #value# &nbsp;&nbsp;
            </cfloop>
        </div>

        <cfloop array="#args.data.products#" index="row">
            <div><h3>#row.title#</h3></div>

            <h3>Dell'articolo</h3>


            <h3>Degli attributi</h3>
            <div>
                <cfloop array="#row.productItems#" item="productItem">
                    <div style="margin-bottom: 7px;">

                    <i style="display:block;">#productItem.attribute.name#: #productItem.attributeValue.rawValue.name# (#productItem.components.len()#) </i>
                    
                    <cfloop array="#productItem.components#" item="component">
                        - <b>#component.quantity# 

                            <cfif component.typeId == "base">
                                + #component.override.quantity# = #component.totalQuantity#
                            </cfif>

                            #component.rawProduct.measurementUnit.id#</b> x #component.rawProduct.name# 
                            - #component.color.name# 
                            - #component.variant.name#<br/>
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
