<cfoutput>

    <div class="row mb-3">
        <div class="col-lg-6">
            <h2>Prodotti</h2>
        </div>
        <div class="col-lg-6">
            <div class="float-end">
                <a type="button" href="/manager/products/new" class="mt-4 me-1 btn btn-primary btn-sm">Carica prodotto &raquo;</a>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-12">
            <section class="card">
                <header class="card-header">
                    <div class="card-actions">
                        <a href="##" class="card-action card-action-toggle" data-card-toggle></a>
                    </div>
                    <h2 class="card-title">Cerca</h2>
                </header>
                <section class="card-body">

                    <div class="row">
                        <div class="col-sm-6">
                            
                            <div class="row pb-3">
                                <label class="col-sm-3 control-label text-sm-end pt-2">
                                    Cerca 
                                </label>

                                <div class="col-sm-9">
                                    <input class="form-control">
                                </div>
                            </div>

                            <div class="row">
                                <label class="col-sm-3 control-label text-sm-end pt-2">
                                    Tipo rapporto 
                                </label>

                                <div class="col-sm-9">
                                    <select class="form-control">
                                        <option value="P">Partner</option>
                                        <option value="C">Cliente</option>
                                    </select>
                                </div>
                            </div>

                            <div class="row">
                                <div class="offset-sm-3 pt-2">
                                    <a type="button" href="/manager/company/new" class="mb-1 mt-1 me-1 btn btn-primary">Cerca &raquo;</a>
                                </div>
                            </div>
    
                        </div>
                    
                    </div>
                </section>
            </section>

            <section class="card mt-1">
                <section class="card-body">

                    <table class="table table-responsive-md table-hover mb-0">
                        <thead>
                            <tr>
                                <th>Codice</th>
                                <th>Prodotto</th>
                                <th>Azienda</th>
                                <th>Prezzo</th>
                                <th>Status</th>
                                <th>Creato il</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop array="#prc.list.getData()#" item="item">
                                <tr>
                                    <td>#item.getCode()#</td>
                                    <td><a href="/manager/products/#item.getId()#">#item.getName()#</a></td>
                                    <!--- <td>#item.getCompany().getName()#</td> --->
                                    <td>#item.getPrice()#</td>
                                    <td>#item.getStatus().getName()#</td>
                                    <td>#item.getCreatedAt()#</td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </div>

</cfoutput>