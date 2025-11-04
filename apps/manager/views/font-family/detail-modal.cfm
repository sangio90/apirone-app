<cfoutput>
    <div id="font-family-detail-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="font-family-detail-form" method="POST" name="font-family-detail-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-start">Codice</label>
                            <div class="col-sm-4">
                                <input type="text" required class="form-control col-sm-4 uppercase" 
                                    name="code"
                                    maxlength="5"
                                    data-bind="value: detailForm.data.code"
                                    >
                            </div>
                            <label class="col-sm-2 col-form-label text-start">Descrizione</label>
                            <div class="col-sm-4">
                                <input type="text" required class="form-control col-sm-4" 
                                    name="name"
                                    maxlength="50"
                                    data-bind="value: detailForm.data.name"
                                    >
                            </div>
                            <label class="col-sm-2 col-form-label"></label>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-start">Dimensioni Font</label>
                            <div class="col-sm-12">
                                
                                #table( 
                                    id="font-family-size-grid",
                                    source = "detailForm.data.sizes",
                                    columns = "[ { field: 'size', title: 'Dimensione' },
                                        { field: 'withPictograms', title: 'Con pittogrammi', width: '15%' } ]",
                                    rowTemplate="font-family-size/font-family-size-grid-row-tmpl"
                                )#

                                #iconButton(bind="click:addSize", icon="plus", id="addSize")#
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
