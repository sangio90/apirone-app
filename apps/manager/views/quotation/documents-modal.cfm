<cfoutput>
    <div id="qt-documents-modal-root" class="modal fade">
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <header class="card-header d-flex align-items-center justify-content-between">
                    <h2 class="card-title">Documenti allegati</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi"></button>
                </header>

                <div class="card-body">

                    <div id="qt-documents-list">
                        <table class="table table-sm table-hover" id="qt-documents-table">
                            <thead>
                                <tr>
                                    <th style="width:40px"></th>
                                    <th>Nome file</th>
                                    <th style="width:90px" class="text-end">Azioni</th>
                                </tr>
                            </thead>
                            <tbody id="qt-documents-tbody">
                            </tbody>
                        </table>
                        <p id="qt-documents-empty" class="text-muted" style="display:none">Nessun documento allegato.</p>
                    </div>

                    <hr>

                    <div class="row align-items-end">
                        <div class="col">
                            <label class="form-label mb-1">Allega nuovo documento</label>
                            <input type="file" id="qt-document-file-input" class="form-control form-control-sm">
                        </div>
                        <div class="col-auto">
                            <button type="button" class="btn btn-primary btn-sm" id="qt-document-upload-btn">
                                <i class="fas fa-upload"></i> Carica
                            </button>
                        </div>
                    </div>
                    <div id="qt-document-upload-status" class="mt-2"></div>

                </div>

                <footer class="card-footer">
                    <button type="button" class="btn btn-default btn-sm float-end" data-bs-dismiss="modal">Chiudi</button>
                </footer>

            </div>
        </section>
    </div>
</cfoutput>
