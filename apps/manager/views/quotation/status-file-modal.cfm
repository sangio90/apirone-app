<cfoutput>
    <div id="qt-status-file-root" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="qt-status-file-form" method="POST" name="qt-status-file-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text: fileForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Nuovo documento</label>
						
							<div class="col-9">
								<input type="file" id="qt-status-file" class="mb-1 form-control" 
									name="statusFile"
									data-bind="events: { change: onFileRowChange }">
							</div>
							
						</div>

					</div>

					<footer class="card-footer">    
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:saveFile">
                                    <i class="fas fa-save"></i> Salva
                                </button>
                                <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                                <div class="save-status errors-counter mt-1 float-end me-3"></div>
                            </div>
                        </div>
                    </footer>

                </form>

            </div>
        </section>
    
    </div>

</cfoutput>