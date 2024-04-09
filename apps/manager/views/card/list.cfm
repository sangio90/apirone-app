<cfoutput>

    <div class="row mb-3">
        <div class="col-lg-12">
            <div class="float-end">
                <a type="button" href="/manager/card/generate" class="mb-1 mt-1 me-1 btn btn-primary">Carica tessere &raquo;</a>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-12">
            <section class="card">

                <header class="card-header">
                    <h2 class="card-title">Lista delle tessere</h2>
                </header>

                <div class="card-body">
                    
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
                                    Cliente
                                </label>

                                <div class="col-sm-9">
                                    <select class="form-control">
                                        <option value="P">-- tutti</option>
                                        <cfloop array="#prc.companies.getData()#" index="index">
                                            <option value="#index.getId()#">#index.getName()#</option>
                                        </cfloop>
                                    </select>
                                </div>
                            </div>

                            <div class="row">
                                <div class="offset-sm-3 pt-2">
                                    <button class="mb-1 mt-1 me-1 btn btn-primary">Cerca &raquo;</button>
                                </div>
                            </div>
    
                        </div>
                    
                    </div>

                    <hr>

                    <table class="table table-responsive-md table-hover mb-0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Generata il</th>
                                <th>Scadenza</th>
                                <th>Valore</th>
                                <th>Azienda</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop array="#prc.list.getData()#" item="item">
                                <tr>
                                    <td><a href="/manager/company/#item.getId()#">#item.getId()#</a></td>
                                    <td>#DateFormat( item.getEmissionAt(), 'dd/mm/yyyy' )#</td>
                                    <td>#DateFormat( item.getExpirationAt(), 'dd/mm/yyyy' )#</td>
                                    <td>#LSCurrencyFormat( item.getAmount() )#</td>
                                    <td>#item.getCompany().getName()#</td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                </div>            
            </section>
        </div>
    </div>

</cfoutput>