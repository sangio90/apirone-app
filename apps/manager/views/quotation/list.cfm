<cfoutput>

    <div class="row mb-3">
        <div class="col-lg-6">
            <h2>Preventivi</h2>
        </div>
        <div class="col-lg-6">
            <div class="float-end">
                <a type="button" href="/manager/quotation" class="mt-4 me-1 btn btn-primary btn-sm">Carica preventivo &raquo;</a>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-12">
            <section class="card">
                <section class="card-body box-search">

                    <form name="estimate-search-form" id="estimate-search-form" method="post">
                        <div class="row">
                            <div class="col-6">
                                <div class="form-group row mb-2">
                                    <label class="col-sm-3 control-label text-sm-end pt-2">Cerca</label>
                                    <div class="col-sm-9">
                                        <input type="text" name="str" class="form-control" placeholder="Cerca nel nome o nel codice">
                                    </div>
                                </div>
                                <div class="form-group row mb-2">
                                    <label class="col-sm-3 control-label text-sm-end pt-2">Stato</label>
                                    <div class="col-sm-9">
                                        <select name="statusId" class="form-control">
                                            <option value="">-- tutti</option>
                                            <option value="ACP">Accettato</option>
                                            <option value="CRE">Creato</option>
                                            <option value="REF">Rifiutato</option>
                                            <option value="REF">Convertito in ordine</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="form-group row mb-2">
                                    <label class="col-sm-3 control-label text-sm-end pt-2">Da da</label>
                                    <div class="col-sm-9">
                                        <input type="date" name="fromDate" class="form-control" placeholder="eg.: 20/05/2020">
                                    </div>
                                </div>
                                <div class="form-group row mb-2">
                                    <label class="col-sm-3 control-label text-sm-end pt-2">A data</label>
                                    <div class="col-sm-9">
                                        <input type="date" name="toDate" class="form-control" placeholder="eg.: 20/05/2020">
                                    </div>
                                </div>
                                <div class="form-group row">
                                    <div class="col-sm-9 offset-sm-3">
                                        <button type="button" class="btn btn-primary btn-sm me-2" data-bind="click:search">
                                        <i class="fas fa-search"></i> Cerca
                                        </button>
                                        <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:print">
                                        <i class="fas fa-print"></i> Stampa
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </form>                    

                </section>
            </section>

            <section class="card mt-1">
                <section class="card-body">

                    <div class="row">
                        <div class="mb-3 d-flex justify-content-end col-12">
                            <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:deleteAll">
                                <i class="fas fa-remove"></i> Cancella selezionati
                            </button>
                            <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:print">
                                <i class="fas fa-print"></i> Stampa
                            </button>
                            <button type="button" class="btn btn-primary btn-sm" data-bind="click:saveAll">
                                <i class="far fa-object-ungroup"></i> Unisci preventivi
                            </button>
                        </div>
                    </div>

                    <table class="table table-responsive-md table-hover mb-0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nome</th>
                                <th>Codice</th>
                                <th>Status</th>
                                <th>Creato il</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop array="#prc.list#" item="item">
                                <tr>
                                    <td>#item.id#</td>
                                    <td><a href="/manager/quotations/#item.id#">#item.name#</a></td>
                                    <td>#item.code#</td>
                                    <td>#item.status#</td>
                                    <td>#item.createdAt#</td>
                                    <td width="30"><input type="checkbox" name="checkboxRow1" class="checkbox-style-1 p-relative top-2" value="" /></td>
                                </tr>
                            </cfloop>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </div>

</cfoutput>