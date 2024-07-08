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
                                <i class="fas fa-save"></i> Salva tutto
                            </button>
                        </div>
                    </div>

                    <table class="table table-responsive-md table-hover mb-0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nome</th>
                                <th>Creato il</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfloop array="#prc.list.getData()#" item="item">
                                <tr>
                                    <td>#item.getId()#</td>
                                    <td><a href="/manager/production-times/#item.getId()#">#item.getName()#</a></td>
                                    <td>#item.getCreatedAt()#</td>
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