<cfoutput>
    <div id="qt-status-modal-root" class="modal fade">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content">

                <form id="qt-status-detail-form" method="POST" name="qt-status-detail-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title">Stati del preventivo</h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

						<nav>
							<ul class="nav nav-tabs" role="tablist">
								<li class="nav-item active">
									<a class="nav-link active" id="qt-status-nav-detail-but" data-bs-toggle="tab" 
										href="##qt-status-nav-detail-tab" role="tab" aria-controls="tab1" aria-selected="true">
										Dettaglio
									</a>                        
								</li>

								<li class="nav-item">
									<a class="nav-link" id="qt-status-nav-grid-but" data-bs-toggle="tab" 
										href="##qt-status-nav-grid-tab" role="tab" aria-controls="tab2" aria-selected="true">
										Storico
									</a>
								</li>
							</ul>

						</nav>

						<div class="tab-content" id="nav-tabContent">

							<div class="tab-pane fade show active" id="qt-status-nav-detail-tab" role="tabpanel" aria-labelledby="qt-status-nav-detail-but">

								<div class="form-group row mb-3">
									<label class="col-3 control-label text-sm-end pt-2">Stato corrente</label>
									<div class="col-9">
										<b><div class="mt-2 fs-14" data-bind="text: detailForm.data.statusHistory.status.name"></div></b>
									</div>
								</div>

								<div class="divider mb-4"></div>

								<div class="form-group row mb-3">
									<label class="col-3 control-label text-sm-end pt-2">Nuovo stato</label>
									<div class="col-9">
										<select name="newStatus" class="form-control"
											data-bind="source: statuses, events: { change: showDocumentRequired }, value: detailForm.data.newStatus"
											data-value-field="id"
											data-text-field="name"
										>
										</select>
									</div>
								</div>

								<div class="form-group row mb-3" id="statusDocumentRow">
									<label class="col-3 control-label text-sm-end pt-2">Documento</label>
								
									<div class="col-9">
										<input type="file" id="statusFile" class="mb-1 form-control" name="statusFile">
									</div>
								
									<label class="col-3 control-label text-sm-end pt-2"></label>
									<div class="col-9">
										<div data-bind="text: detailForm.data.statusFile.name">
										</div>
										<span 
											class="btn btn-default btn-sm" 
											id="documentDownloadButton" 
											data-bind="click: downloadFile, visible: toggleDownloadDocumentButton"
										>
											Scarica Documento
										</span>
									</div>
								
								</div>

							</div>

							<div class="tab-pane fade" id="qt-status-nav-grid-tab" role="tabpanel" aria-labelledby="qt-status-nav-grid-but">

								<div class="tab-pane fade" id="nav-history" role="tabpanel">
									<div class="row mb-3">

										<div class="col-12">
											<form name="qt-status-history-grid-form" id="qt-status-history-grid-form" method="get">

												#grid( 
													id="qt-status-history-grid",
													class="no-pager",
													columns="[
														{ 'field':'createdAt', 'title':'Data', width: '10%'},
														{ 'field':'account', 'title':'Operatore', width: '20%'},
														{ 'field':'status', 'title':'Stato', width: '20%'},
														{ 'field':'', 'title':'', width: '10%'}
													]",
													source="rows",
													rowTemplate="quotation/quotation-status-history-grid-row-tmpl"
												)#

											</form>
										</div>

									</div>
								</div>

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
                                <div class="save-status errors-counter mt-1 float-end me-3"></div>
                            </div>
                        </div>
                    </footer>

                </form>

            </div>
        </section>
    
    </div>

</cfoutput>