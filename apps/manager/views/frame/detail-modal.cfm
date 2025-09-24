<cfoutput>

    <div id="frame-detail-modal" class="modal fade">

        <div class="modal-dialog modal-lg">
            <div class="modal-content">

                <header class="card-header d-flex align-elements-center justify-content-between">
                    <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                </header>

                <div class="card-body">

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
                    <form id="frame-detail-form">

                        <div class="tab-content" id="nav-tabContent">
                        
                            <!---
                                Tab: dettaglio
                            --->

                            <div class="tab-pane fade show active" id="frame-nav-detail-tab" role="tabpanel" aria-labelledby="frame-nav-detail-but">

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
                                    <label class="col-sm-2 col-form-label text-end">Nome</label>
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
                                        <select id="orientationId" class="form-control" name="cellOrientationId"
                                            required
                                            data-bind="source: orientations, value: detailForm.data.cellOrientation" 
                                            data-value-field="id"
                                            data-text-field="name"
                                            >
                                        </select>
                                    </div>
                                </div>

                                
                                <div class="mb-3 row">
                                    <label class="col-sm-2 col-form-label text-end">Stato</label>
                                    <div class="col-sm-10">
                                        <select id="orientationId" class="form-control" name="orientationId"
                                            required
                                            data-bind="source: statuses, value: detailForm.data.status" 
                                            data-value-field="id"
                                            data-text-field="name"
                                            >
                                        </select>
                                    </div>
                                </div>

                                <div class="mb-3 row" data-bind="visible: detailForm.data.id">
                                    <div class="col-sm-10 offset-sm-2 mt-1 fs-10 le-14">
                                        ID: <span data-bind="text: detailForm.data.id"></span><br>
                                        Creato: <span data-bind="text: detailForm.data.createdAt"></span>
                                    </div>
                                </div>
                            
                            </div>

                            <!--- 
                                Tab: griglia
                            --->
                            <div class="tab-pane fade" id="frame-nav-grid-tab" role="tabpanel" aria-labelledby="frame-nav-grid-but">
                                <div class="mb-3 d-flex gap-2">
                                    #addButton( id="add-row-btn", bind="click:addBaseGrid", size="sm", label="Aggiungi griglia base", type="button" )#
                                    <!----
                                    #addButton( id="add-row-btn", bind="click:addRow", size="sm", label="Aggiungi riga", type="button" )#
                                    #removeButton( id="remove-row-btn", bind="click:removeRow", size="sm", label="Rimuovi riga", type="button" )#
                                    &nbsp;&nbsp;
                                    #addButton( id="add-col-btn", bind="click:addCol", size="sm", label="Aggiungi colonna", type="button" )#
                                    #removeButton( id="remove-col-btn", bind="click:removeCol", size="sm", label="Rimuovi colonna", type="button" )#
                                    ---->
                                </div>
                                
                                <div class="table-responsive">
                                    <div data-bind="source: cellsMatrix" data-template="frame-cells-row-tmpl">
                                    </div>
                                    <!---
                                    <table id="frame-cells-table" class="table table-bordered">
                                        <tbody data-bind="source: cellsMatrix" data-template="frame-cells-row-tmpl">
                                        </tbody>
                                    </table>
                                    ---->
                                </div>
                                <p>
                                    <input type="hidden" name="grid">
                                </p>
                                
                                <div class="alert alert-info mt-3">
                                    <small>Inserisci "0" per posizione non utilizzabile o "_" per posizione utilizzabile.</small>
                                </div>
                            </div>

                        </div>
                    </form>
                
                </div>

                <footer class="card-footer">
                    <div class="row">
                        <div class="col-md-12 d-flex justify-content-end">
                            <div class="status errors-counter mt-1 me-3"></div>
                            <button type="button" class="btn btn-default btn-sm me-2" data-bs-dismiss="modal">Chiudi</button>
                            #saveButton(bind="click:save", size="sm")#
                        </div>
                    </div>
                </footer>                

            </div>
        </div>
    </div>

    #template( view="jstemplate/frame/frame-cells-row-tmpl" )#

</cfoutput>