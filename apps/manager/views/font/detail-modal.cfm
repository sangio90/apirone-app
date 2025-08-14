<cfoutput>
    <div id="font-detail-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="font-detail-form" method="POST" name="font-detail-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

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
                            <label class="col-sm-2 col-form-label text-end">Descrizione (it)</label>
                            <div class="col-sm-10">
                                <input type="text" required class="form-control col-sm-4 uppercase" 
                                    name="name"
                                    maxlength="50"
                                    data-bind="value: detailForm.data.nameItem.name"
                                    >
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Font-family</label>
                            <div class="col-sm-10">
                                <input type="text" required class="form-control col-sm-4" 
                                    name="family"
                                    maxlength="100"
                                    data-bind="value: detailForm.data.family"
                                    >
                            </div>
                            <label class="col-sm-2 col-form-label"></label>
                            <div class="field-note col-sm-10">
                                Es. "Source Sans Pro", Arial, sans-serif<br>
                                "Times New Roman", Georgia, serif
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Ingrombro (mm)</label>
                            <div class="col-sm-10">
                                <input type="number" required class="form-control col-sm-4" name="dimension"
                                    data-msg-required="Dimensione richiesta"
                                    data-bind="value: detailForm.data.dimension">
                            </div>
                        </div>

                        <div class="row" data-bind="visible: detailForm.data.id">
                            <label class="col-sm-2 col-form-label text-end">ID</label>
                            <div class="col-sm-10 mt-1">
                                <span data-bind="text: detailForm.data.id"></span>
                            </div>
                        </div>

                        <div class="row" data-bind="visible: detailForm.data.id">
                            <label class="col-sm-2 col-form-label text-end">Directory</label>
                            <div class="col-sm-10 mt-1">
                                <span data-bind="text: detailForm.data.directory"></span>
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