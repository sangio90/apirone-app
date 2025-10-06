<cfoutput>

    <div id="price-type-detail-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="price-type-detail-form" method="POST" name="price-type-detail-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between modal-header--sticky">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                    
                    <div class="card-body">

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">ID</label>
                            <div class="col-sm-10">
                                <input type="text" required class="form-control col-sm-4 uppercase"
                                    name="id"
                                    data-rule-required="true"
                                    data-msg-required="Codice richiesto"
                                    data-bind="value: detailForm.data.id, disabled: isDisabled">
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Nome</label>
                            <div class="col-sm-10">
                                <input type="text" required class="form-control col-sm-4 uppercase" 
                                    name="name"
                                    data-rule-required="true"
                                    data-msg-required="Descrizione richiesta"
                                    maxlength="125"
                                    data-bind="value: detailForm.data.name">
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Metodi</label>
                            <div class="col-sm-10">
                                <select id="methods" 
                                    data-role="multiselect" 
                                    data-bind="source: detailForm.methods, value: detailForm.data.selectedMethods" 
                                    data-value-field="id"
                                    data-text-field="name"
                                    >
                                </select>
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Usa in</label>
                            <div class="col-sm-10">
                                <select id="entities" 
                                    data-role="multiselect" 
                                    data-bind="source: detailForm.entities, value: detailForm.data.selectedEntities" 
                                    data-value-field="id"
                                    data-text-field="name"
                                    >
                                </select>
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Stato</label>
                            <div class="col-sm-10">
                                <select 
                                    required
                                    id="statusId" 
                                    class="form-control"
                                    data-bind="source: detailForm.statuses, value: detailForm.data.status" 
                                    data-value-field="id"
                                    data-text-field="name"
                                    >
                                </select>
                            </div>
                        </div>

                        <div class="mb-3 row" data-bind="visible: detailForm.isEdit">
                            <div class="col-sm-10 offset-sm-2 mt-1 fs-10 le-14">
                                Creato: <span data-bind="text: detailForm.data.createdAt"></span>
                            </div>
                        </div>

                    </div>

                    <footer class="card-footer modal-footer--sticky">
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