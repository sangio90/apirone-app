<cfoutput>
    <div id="role-detail-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="role-detail-form" method="POST" name="role-detail-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

                        <div class="mb-3 row">
                            <label class="col-sm-3 col-form-label text-end">Offerta massima</label>
                            <div class="col-sm-9">
                                <input type="text" class="form-control col-sm-4" 
                                    name="quotationMaxAmount"
                                    maxlength="5"
                                    data-bind="value: detailForm.data.quotationMaxAmount">
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-3 col-form-label text-end">Sconto massimo</label>
                            <div class="col-sm-9">
                                <input type="text" class="form-control col-sm-4" 
                                    name="quotationMaxDiscount"
                                    data-bind="value: detailForm.data.quotationMaxDiscount">
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
        </section>
    
    </div>

</cfoutput>
