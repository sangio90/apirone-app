<cfoutput>

    <div class="row mb-3">
        <div class="col-lg-12">
            <section class="card">
                <header class="card-header">
                    <h2 class="card-title">Cerca transazioni</h2>
                </header>
                <div class="card-body">
                    <form class="horizontal-form">
                        <div class="row">
                            <div class="form-group col-3">
                                <label class="form-label">Da data</label>
                                <div class="custom-select-1">
                                    <input type="date" class="form-control">
                                </div>
                            </div>
                            <div class="form-group col-3">
                                <label class="form-label">A data</label>
                                <div class="custom-select-1">
                                    <input type="date" class="form-control">
                                </div>
                            </div>
                            <div class="form-group col-3">
                                <label class="form-label">Categoria</label>
                                <div class="custom-select-1">
                                    <select class="form-control">
                                        <option value="">-- seleziona</option>
                                        <option value="1">Food</option>
                                        <option value="1">Moda</option>
                                        <option value="1">Experience</option>
                                        <option value="1">Wellness</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group col-3">
                                <label class="form-label">Fornitore</label>
                                <div class="custom-select-1">
                                    <select class="form-control">
                                        <option value="">-- seleziona</option>
                                        <option value="1">Dolce & Gabbana</option>
                                        <option value="1">TODS</option>
                                        <option value="1">Ristorante il Falco</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12">
                                <a type="button" href="/manager/companies/new" class="mb-1 mt-1 me-1 btn btn-primary">Cerca &raquo;</a>
                            </div>
                        </div>
                    </form>
                </div>

            </section>
        </div>
    </div>    

    <div class="row mb-3">
        <div class="col-lg-12">
            <section class="card">
                <header class="card-header">
                    <h2 class="card-title">#arc.title#</h2>
                </header>
                <div class="card-body">

                    <div class="pt-4">

                        <div class="container">
                
                            <div class="row">

                                <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th weight="50"></th>
                                        <th>Partner</th>
                                        <th>## Vendite</th>
                                        <th>Totale</th>
                                        <th>Commissione</th>
                                        <th>Da restituire</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfloop array="#prc.list#" index="item">
                                    <tr>
                                        <td></td>
                                        <td>#item.company#</td>
                                        <td>#item.salesCount#</td>
                                        <td>#item.totalSale#</td>
                                        <td>#item.totalCommission#</td>
                                        <td>#item.toReturned#</td>
                                        <td><input type="checkbox"></td>
                                    </tr>
                                    </cfloop>
                                </tbody>
                                </table>

                                <p class="text-end">
                                    <button class="btn btn-primary" onlclik="location.href='/manager/catalogue/complete'">Segna come completato</button>
                                </p>

                            </div>
                        
                        </div>
                
                    </div>                    

                </div>
            </section>
        </div>
    </div>

</cfoutput>