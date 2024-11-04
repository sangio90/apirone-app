<cfoutput>

    <div id="attribute-detail-values-modal" class="modal fade">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content">

                <header class="card-header">
                    <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                </header>                

                <nav>
                    <div class="nav nav-tabs" id="nav-tab" role="tablist">
                        <button class="nav-link active" id="attribute-nav-detail-but" data-bs-toggle="tab" type="button" role="tab"
                            data-bs-target="##attribute-nav-detail-tab" aria-controls="attribute-nav-detail-tab" aria-selected="true">
                                Dettaglio
                        </button>
                        <button class="nav-link" id="attribute-nav-values-but" data-bs-toggle="tab"  type="button" role="tab"
                            data-bs-target="##attribute-nav-values-tab" aria-controls="attribute-nav-values-tab" aria-selected="false">
                                Valori
                        </button>
                    </div>
                </nav>

                <div class="tab-content" id="nav-tabContent">

                    <!--- panel 1 ---->
                    <div class="tab-pane fade show active" id="attribute-nav-detail-tab" role="tabpanel" aria-labelledby="attribute-nav-detail-but">                

                        <form id="attribute-detail-form" method="POST" name="attribute-detail-form">
                        
                            <div class="card-body">

                                <div class="mb-3 row">
                                    <label for="attrId" class="col-sm-2 col-form-label text-end">ID</label>
                                    <div class="col-sm-10">
                                        <input type="text" required class="form-control col-sm-4" id="attrId" name="attrId"
                                            maxlength="10"
                                            data-bind="value: detailForm.data.id"
                                            onkeyup="this.value = this.value.toUpperCase();">
                                    </div>
                                </div>

                                <div class="mb-3 row">
                                    <label for="statusId" class="col-sm-2 col-form-label text-end">Status</label>
                                    <div class="col-sm-10">
                                        <select type="text" class="form-control" name="statusId"
                                            required
                                            data-bind="value: detailForm.data.status.id, source: statusList"
                                            data-value-field="id"
                                            data-text-field="name">
                                        </select>
                                    </div>
                                </div>

                                <div class="mb-3 row">
                                    <label for="attr" class="col-sm-2 col-form-label text-end">Descrizione (it)</label>
                                    <div class="col-sm-10">
                                        <input type="text" required class="form-control col-sm-4" id="attr" name="attr"
                                            maxlength="10"
                                            data-bind="value: getTextName"
                                        >
                                    </div>
                                </div>

                                <!---
                                <div data-bind="source: detailForm.data.texts" data-template="attribute-lang-row-tmpl" class="mt-3">
                                </div>
                                ---->
                            
                            </div>

                            <footer class="card-footer">
                                <div class="row">
                                    <div class="col-md-12 float-end">
                                        <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:save">
                                            <i class="fas fa-save"></i> Salva dettaglio
                                        </button>
                                        <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                                        <div class="status errors-counter mt-1 float-end me-3"></div>
                                    </div>
                                </div>
                            </footer>

                        </form>

                    </div>

                    <!--- panel 2 ---->
                    <div class="tab-pane fade" id="attribute-nav-values-tab" role="tabpanel" aria-labelledby="attribute-nav-values-but">

                            <div class="card-body">

                                <form id="attribute-values-add-form" method="POST" name="attribute-values-add-form">

                                    <div class="row mb-3">
                                        <label for="newValueName" class="col-sm-2 text-end">Descrizione (it)</label>
                                        <div class="col-sm-10">
                                            <input type="text" class="form-control" id="newValueName" name="newValueName" required
                                                data-bind="value: valueForm.data.name">
                                        </div>
                                    </div>
                                    
                                    <div class="row mb-3">
                                        <label for="newValueStatus" class="col-sm-2 text-end">Stato</label>
                                        <div class="col-sm-10">
                                            <select type="text" class="form-control" name="newValueStatus" id="newValueStatus"
                                                required
                                                data-bind="value: valueForm.data.status.id, source: statusList"
                                                data-value-field="id"
                                                data-text-field="name">
                                            </select>
                                        </div>
                                    </div>
                                    
                                    <div class="row mb-3">
                                        <div class="col-sm-10 offset-md-2">
                                            <button type="button" class="btn btn-primary btn-sm" data-bind="click:saveValue">
                                                <i class="fas fa-add"></i> Aggiungi
                                            </button>
                                        </div>
                                    </div>
                                    
                                </form>


                                <form id="attribute-values-form" method="POST" name="attribute-values-form">
                                    <div data-bind="source: detailForm.data.values" data-template="attribute-lang-row-tmpl" class="mt-3">
                                    </div>
                                </form>
                            
                            </div>

                            <footer class="card-footer">
                                <div class="row">
                                    <div class="col-md-12 float-end">
                                        <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:save">
                                            <i class="fas fa-save"></i> Salva valori
                                        </button>
                                        <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                                        <div class="status errors-counter mt-1 float-end me-3"></div>
                                    </div>
                                </div>
                            </footer>

                        </form>
                    </div>
                </div>

            </div>
        </selection>
    
    </div>

    #template( view="jstemplate/attribute/lang-row" )#

</cfoutput>