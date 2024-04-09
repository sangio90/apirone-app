<cfoutput>

    <cfset attr = prc.printParams.getAttributes().toStruct()>

    <cfdocument format="pdf" attributeCollection="#attr#">

        <style type="text/css">
            td, th, span, div { font-family: "Arial"; font-size: 15px }
        </style>

        <cfdocumentitem type="header">
            #getPrintHeader( prc.printParams.getTitle() )#
        </cfdocumentitem>

        <h2 style="font-family: Lora">#prc.printParams.getTitle()#</h2>

        <table width="100%" border=0 style="border-collapse:collapse">
            <tr style="background-color: ##EAEAEA">
                <cfloop array="#prc.printParams.getColumns()#" index="column">
                    <th>#column.getTitle()#</th>    
                </cfloop>
            </tr>
            <cfset n = 1>
            <cfloop array="#prc.printParams.getRows()#" index="row">
                <tr>
                    <cfloop array="#prc.printParams.getColumns()#" index="item">
                        <cfif item.getField() CONTAINS "[]">

                            <cfset values = []>

                            <cfset field = ListFirst( item.getField(), '[]' )>
                            <cfset path = ListLast( item.getField(), '[]' )>

                            <cfloop item="line" array="#row[ field ]#">
                                <cfset thisValue = StructGet('line.#path#')>
                                <cfset values.add( thisValue )>
                            </cfloop>

                            <cfset value = values.toList(", ")>

                        <cfelse>
                            
                            <cfset field = item.getField()>
                            <cfset value = StructGet('row.#field#' )>

                            <cfif Len( item.getHelper() )>
                                <cfset command = Replace( item.getHelper(), "$field", "'#value#'" )>
                                <cfset value = Evaluate( command )>
                            </cfif>
    
                        </cfif>
                        
                        <td align="#item.getAlign()#" style="#item.getStyle()#"><cfif IsSimpleValue( value )>#value#</cfif></td>
                    </cfloop>
                </tr>      
                <cfset n++>
            </cfloop>
        </table>
        
        <cfdocumentitem type="footer">
            #getPrintFooter()#
        </cfdocumentitem>
    
    </cfdocument>

</cfoutput>
