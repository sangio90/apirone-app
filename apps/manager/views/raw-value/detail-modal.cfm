<cfoutput>

    <div id="raw-value-detail-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <header class="card-header d-flex align-elements-center justify-content-between">
                    <h2 class="card-title" data-bind="text:getTitleForm"></h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                </header>

                <nav>

                    <ul class="nav nav-tabs" role="tablist">
                        <li class="nav-item active">
                            <a class="nav-link active" id="raw-value-nav-detail-but" data-bs-toggle="tab" 
                                href="##raw-value-nav-detail-tab" role="tab" aria-controls="tab1" aria-selected="true">
                                Dettaglio
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" id="raw-value-nav-metadata-but" data-bs-toggle="tab" 
                                href="##raw-value-nav-metadata-tab" role="tab" aria-controls="tab2" aria-selected="true">
                                Metadati
                            </a>
                        </li>
                    </ul>

                </nav>

                <div class="tab-content" id="nav-tabContent">

                    <div class="tab-pane fade show active" id="raw-value-nav-detail-tab" role="tabpanel" aria-labelledby="raw-value-nav-detail-but">

                        <div class="card-body">
                            <form id="raw-value-detail-form" method="POST" name="raw-value-detail-form">
                            
                                <div class="">

                                    <div class="mb-3 row">
                                        <label class="col-sm-2 col-form-label text-end">Codice</label>
                                        <div class="col-sm-10">
                                            <input type="text" required class="form-control col-sm-4 uppercase" name="code" id="code"
                                                maxlength="5"
                                                data-rule-required="true"
                                                data-msg-required="Codice richiesto"
                                                data-bind="value: detailForm.data.code">
                                        </div>
                                    </div>

                                    <div class="mb-3 row">
                                        <label for="rawValueName" class="col-sm-2 col-form-label text-end">Descrizione (it)</label>
                                        <div class="col-sm-10">
                                            <input type="text" required class="form-control col-sm-4 uppercase" id="rawValueName" name="rawValueName"
                                                data-bind="value: detailForm.data.nameItem.name"
                                            >
                                        </div>
                                    </div>

                                    <div class="mb-3 row">
                                        <label for="rawValueStatusId" class="col-sm-2 col-form-label text-end">Stato</label>
                                        <div class="col-sm-10">
                                            <select type="text" class="form-control" name="rawValueStatusId" id="rawValueStatusId"
                                                required
                                                data-bind="source: statusList, value: detailForm.data.status.id"
                                                data-value-field="id"
                                                data-text-field="name">
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

                            </form>                
                        </div>

                    </div>

                    <!--- tab 2 --->
                    <div class="tab-pane fade" id="raw-value-nav-metadata-tab" role="tabpanel" aria-labelledby="raw-value-nav-metadata-but">

                        <div class="card-body">

                            <div class="mb-3 row">
                                <label for="rawValueStatusId" class="col-sm-2 col-form-label text-end">ALTEZZA</label>
                                <div class="col-sm-10">
                                    <input type="text" required class="form-control col-sm-4 uppercase" id="rawValueName" name="rawValueName"
                                    >
                                </div>
                            </div>

                            <div class="mb-3 row">
                                <label for="rawValueStatusId" class="col-sm-2 col-form-label text-end">LARGHEZZA</label>
                                <div class="col-sm-10">
                                    <input type="text" required class="form-control col-sm-4 uppercase" id="rawValueName" name="rawValueName"
                                    >
                                </div>
                            </div>
                        
                        </div>

                    </div>

                </div>

                <footer class="card-footer">
                    <div class="row">
                        <div class="col-md-4 white-small">
                            #relevantPath( getCurrentTemplatePath() )#
                        </div>
                        <div class="col-md-8 d-flex justify-content-end">
                            <div class="status errors-counter mt-1 me-3"></div>
                            <button type="button" class="btn btn-default btn-sm me-2" data-bs-dismiss="modal">Chiudi</button>
                            #saveButton(bind="click:save", size="sm")#
                        </div>
                    </div>
                </footer>                

            </div>
        </selection>

    </div>

    #template( view="jstemplate/raw-value/raw-value-suggest-row-tmpl" )#

</cfoutput>