<cfoutput>
    <div class="row">
        <div class="col-lg-12">
            <section class="card">
                <header class="card-header">
                    <h2 class="card-title">#prc.title#</h2>
                </header>
                <div class="card-body">
                    <form>
                        <table class="table table-responsive-md table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>Prodotto</th>
                                    <th>Quantità</th>
                                    <th>Prezzo</th>
                                    <th>Stato</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfloop array="#prc.detail.getItems()#" item="item">
                                    <tr>
                                        <td>#item.getProductVariant().getName()#</td>
                                        <td>#item.getQuantity()#</td>
                                        <td>#item.getPrice()#</td>
                                        <td>
                                            <select clas="form-control">
                                                <option>Contabilizzato</option>
                                                <option>Non contabilizzato</option>
                                            </select>
                                        </td>
                                    </tr>
                                </cfloop>
                            </tbody>
                        </table>
                    </form>
                </div>
            </section>
        </div>
    </div>

</cfoutput>