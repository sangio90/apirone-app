<cfoutput>

    <cfdocument attributeCollection="#args.pdfArgs#">

        <cfdocumentitem type="header">
            #getPrintHeader()#
        </cfdocumentitem>

        <cfdocumentitem type="footer">
            #getPrintFooter()#
        </cfdocumentitem>

        #importPrintStyle()#

        <h2>#args.title#</h2>

        <div>
            <cfloop collection="#args.filters#" item="value" index="key">
                Filtri: <b>#key#:</b> #value# &nbsp;&nbsp;
            </cfloop>
        </div>

        <cfset blundlesPrinted = {}>

        <cfloop array="#args.data.products#" index="product">

            <div style="border-bottom:1px solid ##EAEAEA; padding: 15px 0"></div>

            <div><h3>Articolo: #product.title#</h3></div>

            <cfset key = product.line.id & '__' & product.model.id>

            <!--- l stampiamo una volta soltanto --->
            <cfif product.bundle.keyExists( key ) AND !blundlesPrinted.keyExists( key )>
                <div style="background-color: ##EAEAEA; padding: 10px;">
                    <h3>Linea/modello</h3>
                    <div>
                        #printComponents( product.bundle[ key ] )#
                    </div>  

                    <cfset blundlesPrinted[ "#lineId#__#modelId#" ] = true>
                </div>

            </cfif>

            <h3>Dell'articolo</h3>
            <div>
                #printComponents( product.components )#
            </div>  

            <h3>Degli attributi</h3>
            <div>
                <cfloop array="#product.productItems#" item="productItem">
                    <div style="margin-bottom: 7px;">
                        <i style="display:block;">#productItem.attribute.name#: #productItem.attributeValue.rawValue.name# (#productItem.components.len()#) </i>
                        #printComponents( productItem.components )#
                    </div>
                </cfloop>
            </div>            
        </cfloop>
    
    </cfdocument>

</cfoutput>
