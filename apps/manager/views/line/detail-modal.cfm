<cfoutput>
    <div id="line-detail-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="line-detail-form" method="POST" name="line-detail-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Codice</label>
                            <div class="col-sm-10">
                                <input type="text" required class="form-control col-sm-4" 
                                    name="code"
                                    maxlength="5"
                                    data-bind="value: detailForm.data.code"
                                    onkeyup="this.value = this.value.toUpperCase();">
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Descrizione</label>
                            <div class="col-sm-10">
                                <input type="text" required class="form-control col-sm-4 uppercase" name="name"
                                    data-msg-required="Descrizione richiesto"
                                    maxlength="125"
                                    data-bind="value: detailForm.data.mainText.name">
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Categorie</label>
                            <div class="col-sm-10">
                                <select id="categories" 
                                    data-placeholder="-- Seleziona le categorie"
                                    data-role="multiselect" 
                                    data-bind="source: detailForm.categories, value: detailForm.data.selectedCategories" 
                                    data-value-field="id"
                                    data-text-field="name"
                                    >
                                </select>
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Stato</label>
                            <div class="col-sm-10">
                                <select id="statusId" class="form-control"
                                    required
                                    data-bind="source: detailForm.statuses, value: detailForm.data.status.id" 
                                    data-value-field="id"
                                    data-text-field="name"
                                    >
                                </select>
                            </div>
                        </div>

                        <div class="mb-3 row" data-bind="visible: detailForm.data.id">
                            <label class="col-sm-2 col-form-label text-end">ID</label>
                            <div class="col-sm-10 mt-1">
                                <span data-bind="text: detailForm.data.id"></span>
                            </div>
                        </div>

                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:save">
                                    <i class="fas fa-save"></i> Salva
                                </button>
                                <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                                <div class="status errors-counter mt-1 float-end me-3"></div>
                            </div>
                        </div>
                    </footer>

                </form>

            </div>
        </selection>
    
    </div>

</cfoutput>