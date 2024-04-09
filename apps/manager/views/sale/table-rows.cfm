<cfoutput>

    <table class="table table-hover" style="width: 100%">

    <cfloop collection="#prc.list#" item="company">

        <cfset companyId = prc.list[company][1].getProduct().getCompany().getId()>
        <cfset companyName = prc.list[company][1].getProduct().getCompany().getName()>
        
        <thead>
            <tr>
                <td colspan="8" style="background-color: ##fffecd">
                    <div class="p-1">
                        <div class="float-start">
                            Partner: <b>#companyName#</b>
                        </div>
                        <div class="float-end" id="totalPrice_#companyId#">
                        </div>
                    </div>
                </td>
            </tr>
            <tr>
                <th weight="50">Articolo</th>
                <th>Qta</th>
                <th align="right" class="text-end">Prezzo</th>
                <th align="right" class="text-end">% comm.</th>
                <th align="right" class="text-end">Valore comm.</th>
                <th align="right" class="text-end">Saldo</th>
                <th align="right" class="text-end">Stato</th>
                <th align="right" class="no-print"><input class="float-end" type="checkbox" onclick="ZB.sales.checkAll( '#companyId#', this )"></th>
            </tr>
        </thead>
        <tbody>
            <cfloop array="#prc.list[company]#" index="item">

                <cfset commission = (item.getPrice() / 100 * 3) * 1.22>
                <cfset balance = (item.getPrice() - commission )>

                <tr>
                    <td><em>#item.getProduct().getShortId()#</em> #item.getProduct().getName()# - #item.getProductVariant().getName()#</td>
                    <td>#item.getQuantity()#</td>
                    <td align="right">#LsCurrencyFormat( item.getPrice() )#</td>
                    <td align="right">3%</td>
                    <td align="right">#LsCurrencyFormat( commission )#</td>
                    <td align="right">#LsCurrencyFormat( balance )#</td>
                    <td align="right">
                        #item.getStatus().getName()#
                    </td>
                    <td align="right" class="no-print">
                        <input type="checkbox" name="selected_#companyId#"
                            data-balance="#NumberFormat( balance, '.00' )#" <!--- arrotondamento compreso --->
                            onclick="ZB.sales.selectItem( '#companyId#' )">
                    </td>
                </tr>

            </cfloop>
        </tbody>
    </cfloop>
    <tfoot>
    <tr>
        <td colspan="2"></td>
        <td><b>TOTALE</b></td>
        <td></td>
    </tr>
    </tfoot>
    </table>

</cfoutput>