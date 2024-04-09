<cfoutput>

    <div class="row mb-3" id="cart">
            
        <div class="col-lg-12">
            <section class="card">
                <header class="card-header">
                    <h2 class="card-title">#prc.title#</h2>
                </header>
                <div class="card-body">

                    <div class="pt-4">

                        <div class="container">
                
                            <div class="row">

                                <cfif !StructIsEmpty( prc.cart )>

                                    <form id="cart-form" method="post" action="/manager/cart/save">

                                        <table class="table table-hover">
                                        <cfloop collection="#prc.cart#" item="company">

                                            <cfset companyId = prc.cart[company][1].getProduct().getCompany().getId()>
                                            <cfset companyName = prc.cart[company][1].getProduct().getCompany().getName()>
                                            
                                            <thead>
                                                <tr>
                                                    <td colspan="5" style="background-color: ##fffecd">
                                                        <div class="p-1">Partner: <b>#companyName#</b></div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th weight="50"></th>
                                                    <th>Articolo</th>
                                                    <th>Quantità</th>
                                                    <th align="right">Prezzo</th>
                                                    <th></th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <cfloop array="#prc.cart[company]#" index="item">

                                                    <tr>
                                                        <td weight="50"><img src="#item.getProduct().getImage().getPath()#" width="50" height="50"></td>
                                                        <td>#item.getProduct().getName()# - #item.getVariant().getName()#</td>
                                                        <td>#item.getQuantity()#</td>
                                                        <td align="right">#LsCurrencyFormat( item.getPrice() )#</td>
                                                        <td><a href="/manager/cart/#item.getVariant().getId()#/delete"><i class="fas fa-trash"></i></a></td>
                                                    </tr>
                                                </cfloop>
                                                <tr>
                                                    <td colspan=5>
                                                        <div class="p-1">

                                                            <b>Consegna</b> i prodotti:

                                                            <div class="form-check">
                                                                <input class="form-check-input" type="radio" value="#CreateUUID()#" id="shipTo_#companyId#" name="shipTo_#companyId#"
                                                                    data-rule-required="true"
                                                                    data-msg-required="Seleziona dove consegnare la merce di #companyName#"
                                                                >
                                                                <label class="form-check-label" for="shipTo_#companyId#">
                                                                    ritiro presso #companyName#
                                                                </label>
                                                            </div>

                                                            <div class="form-check">
                                                                <input class="form-check-input" type="radio" value="#CreateUUID()#" id="shipTo_#companyId#" name="shipTo_#companyId#">
                                                                <label class="form-check-label" for="shipTo_#companyId#">
                                                                    indirizzo della mia residenza
                                                                </label>
                                                            </div>
                                                            <div id="shipTo_#companyId#-error"></div>
                                                            
                                                        </div>

                                                    </td>
                                                </tr>
                                            </tbody>
                                        </cfloop>
                                        <tfoot>
                                        <tr>
                                            <td colspan="2"></td>
                                            <td><b>TOTALE</b></td>
                                            <td>#LsCurrencyFormat( prc.total )#</td>
                                        </tr>
                                        </tfoot>
                                        </table>

                                        <p class="text-end">
                                            <button class="btn btn-primary" type="submit">Completa acquisto</button>
                                        </p>

                                    </form>

                                <cfelse>

                                    <p>Il carrello è vuoto</p>

                                </cfif>

                            </div>
                        
                        </div>
                
                    </div>                    

                </div>
            </section>
        </div>
    </div>

</cfoutput>