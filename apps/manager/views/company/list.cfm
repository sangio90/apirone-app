<cfoutput>

    <!----
    <cfdump var="#flash.get("message")#">
    <cfabort>
    ---->

    <div class="row mb-3">
        <div class="col-lg-12">
            <div class="float-end">
                <a type="button" href="/manager/companies/new" class="mb-1 mt-1 me-1 btn btn-primary">Carica azienda &raquo;</a>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-12">
            <section class="card">

                <header class="card-header">
                    <h2 class="card-title">Lista delle aziende</h2>
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

                    <hr>

                    <table class="table table-responsive-md table-hover mb-0">
                        <thead>
                            <tr>
                                <th>##</th>
                                <th>Azienda</th>
                                <th>Tipi</th>
                                <th>Email</th>
                                <th>Telefono</th>
                                <th>Città</th>
                                <th>Partita Iva</th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop array="#prc.list.getData()#" item="item">
                                <tr>
                                    <td><a href="/manager/companies/#item.getId()#">#item.getCode()#</a></td>
                                    <td>#item.getName()#</td>
                                    <td>
                                        <cfloop array="#item.getTypes()#" index="index">
                                            #index.getName()#
                                        </cfloop>
                                    </td>
                                    <td>#item.getAccount().getLogin()#</td>
                                    <td>#item.getPhone()#</td>
                                    <td>#item.getLocation().getCity().getName()#</td>
                                    <td>#item.getVat()#</td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                </div>            
            </section>
        </div>
    </div>

</cfoutput>