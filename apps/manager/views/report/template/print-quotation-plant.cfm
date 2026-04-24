<cfoutput>
    <cfdocument attributeCollection="#args.pdfArgs#" marginTop="1" marginLeft="1" marginRight="1" marginBottom="1">
        <cfif args.pdfArgs.orientation EQ "landscape">
            <cfset containerHeight = "15cm"> <cfset imgMaxWidth = "26cm">    
        <cfelse>
            <cfset containerHeight = "24cm"> <cfset imgMaxWidth = "19cm">    
        </cfif>
        <cfdocumentitem type="header">
            <div style="padding-top: 0.5cm;">
                <h4 style="text-align: center; font-family: sans-serif; margin: 0;">
                    Stampa Pianta preventivo "#args.data.quotation.getName()#"<br>
                    Zona "#args.data.zone.getName()#"
                </h4>
            </div>
        </cfdocumentitem>

        <div style="width: 100%; height: #containerHeight#; display: flex; align-items: center; justify-content: center; overflow: hidden;">
            <img src="#args.data.image#" 
                 style="display: block; margin: 0 auto; width: 100%; max-width: #imgMaxWidth#; height: #containerHeight#;" />
        </div>

        <cfdocumentitem type="pagebreak" />

        <div style="padding: 0.5cm 0 0 0;">
            <h4 style="text-align: center; font-family: sans-serif; margin: 0 0 0.5cm 0;">
                Elementi preventivo
            </h4>
            <table>
                <cfloop array="#args.data.quotationItems#" item="quotationItem">
                    <tr>
                        <td>
                            #quotationItem.getProduct().getCategory().getName()# #quotationItem.getProduct().getLine().getName()# #quotationItem.getProduct().getModel().getName()# #quotationItem.getProduct().getFinish().getCode()# <br>
                            - Qtà: #quotationItem.getQuantity()# <br>
                            <cfloop array="#quotationItem.getPositions()#" item="position">
                                <div>
                                    <cfif quotationItem.getPosition() NEQ "">
                                        - Posizione: #quotationItem.getPosition()# #position.getSequence()#
                                    <cfelse>
                                        - Posizione: senza posizione #position.getSequence()#
                                    </cfif>
                                </div>
                            </cfloop>
                        </td>
                    </tr>
                </cfloop>
            </table>
        </div>
    </cfdocument>
</cfoutput>