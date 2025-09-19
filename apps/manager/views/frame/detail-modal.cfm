<cfoutput>
<div class="modal fade" id="frame-detail-modal">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="frameDetailLabel">Dettaglio Armatura</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi"></button>
            </div>
            <div class="modal-body">

                <nav>
                    <!-- Tabs -->
                    <ul class="nav nav-tabs" role="tablist">
                        <li class="nav-item active">
                            <a class="nav-link active" id="frame-nav-detail-but" data-bs-toggle="tab" 
                                href="##frame-nav-detail-tab" role="tab" aria-controls="tab1" aria-selected="true">
                                Dettaglio
                            </a>                        
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" id="frame-nav-grid-but" data-bs-toggle="tab" 
                                href="##frame-nav-grid-tab" role="tab" aria-controls="tab2" aria-selected="true">
                                Griglia
                            </a>
                        </li>
                    </ul>

                </nav>
                <div class="tab-content" id="nav-tabContent">
                
                    <!-- Tab Content: Anagrafica -->
                    <div class="tab-pane fade show active" id="frame-nav-detail-tab" role="tabpanel" aria-labelledby="frame-nav-detail-but">
                        <form id="frame-detail-form">

                            <div class="mb-3 row">
                                <label class="col-sm-2 col-form-label text-end">Codice</label>
                                <div class="col-sm-10">
                                    <input type="text" required class="form-control col-sm-4 uppercase" 
                                        name="code"
                                        maxlength="5"
                                        data-bind="value: detailForm.data.code"
                                        >
                                </div>
                            </div>
                            
                            <div class="mb-3 row">
                                <label class="col-sm-2 col-form-label text-end">Codice</label>
                                <div class="col-sm-10">
                                    <input type="text" required class="form-control col-sm-4 uppercase" 
                                        name="name"
                                        maxlength="200"
                                        data-bind="value: detailForm.data.name"
                                        >
                                </div>
                            </div>

                            
                            <div class="mb-3 row">
                                <label class="col-sm-2 col-form-label text-end">Orientamento</label>
                                <div class="col-sm-10">
                                    <select id="orientationId" class="form-control" name="orientationId"
                                        required
                                        data-bind="source: statuses, value: detailForm.data.orientation" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>

                            <div class="mb-3 row">
                                <label class="col-sm-2 col-form-label text-end">Orientamento</label>
                                <div class="col-sm-10">
                                    <select id="orientationId" class="form-control" name="orientationId"
                                        required
                                        data-bind="source: orientations, value: detailForm.data.orientation" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>

                            
                            <div class="mb-3 row">
                                <label class="col-sm-2 col-form-label text-end">Orientamento celle</label>
                                <div class="col-sm-10">
                                    <select id="orientationId" class="form-control" name="orientationId"
                                        required
                                        data-bind="source: detailForm.statuses, value: detailForm.data.cellOrientation" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>

                        </form>
                    </div>

                    <!-- Tab Content: Posizioni -->
                    <div class="tab-pane fade show active" id="frame-nav-grid-tab" role="tabpanel" aria-labelledby="frame-nav-grid-but">
                        <div class="mb-3 d-flex gap-2">
                            <button id="add-row-btn" class="btn btn-outline-primary" data-bind="click: addRow">Aggiungi rigax</button>
                            <button id="remove-row-btn" class="btn btn-outline-danger" data-bind="click: removeRow">Rimuovi riga</button> <!--- enable: gridRows > 1 ---->
                            <button id="add-col-btn" class="btn btn-outline-primary" data-bind="click: addCol">Aggiungi colonna</button>
                            <button id="remove-col-btn" class="btn btn-outline-danger" data-bind="click: removeCol">Rimuovi colonna</button> <!---- enable: gridCols > 1 ---->
                        </div>
                        
                        <div class="table-responsive">
                            <table id="frame-cells-table" class="table table-bordered">
                                <tbody data-bind="source: cellsMatrix" data-template="frame-cells-row-tmpl">
                                </tbody>
                            </table>
                        </div>
                        
                        <div class="alert alert-info mt-3">
                            <small>Inserisci "0" per posizione occupata o "_" per posizione vuota</small>
                        </div>
                    </div>

                </div>

            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-bs-dismiss="modal">Chiudi</button>
                <button id="save-grid-btn" type="button" class="btn btn-primary" data-bind="click: save"> <!--- , disable: loading ---->
                    <span data-bind="visible: loading" class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>
                    Salva
                </button>
            </div>

        </div>
    </div>
</div>

#template( view="jstemplate/frame/frame-cells-row-tmpl" )#

</cfoutput>