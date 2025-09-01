<cfoutput>
    <div id="plate-modal-root" class="modal fade">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content">

                <form id="line-detail-form" method="POST" name="line-detail-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

                        <div class="mb-3 row">
                            <div class="col-6">
                                <div class="row">
                                    <div class="col-6">
                                        <label class="col-sm-2 col-form-label text-end">Linea</label>
                                        <div class="col-sm-10">
                                            <select id="plateLineId" 
                                                class="form-control"
                                                data-placeholder="-- Seleziona la linea"
                                                data-bind="source: lines" 
                                                data-value-field="id"
                                                data-text-field="name"
                                                >
                                            </select>
                                        </div>
                                    </div>

                                    <div class="col-6">
                                        <label class="col-sm-2 col-form-label text-end">Modello</label>
                                        <div class="col-sm-10">
                                            <select id="plateModelId" 
                                                class="form-control"
                                                data-placeholder="-- Seleziona il modello"
                                                data-bind="source: models" 
                                                data-value-field="id"
                                                data-text-field="name"
                                                >
                                            </select>
                                        </div>
                                    </div>

                                </div>
                            </div>
                            
                            <div class="col-6">    
								<!--- degigner --->
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