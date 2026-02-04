<cfoutput>
    <div id="article-modal-root" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="article-detail-form" method="POST" name="article-detail-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text: detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Servizio</label>
							<div class="col-9">
								<select name="article" class="form-control"
									data-bind="source: articles, value: detailForm.data.quotationItem.article, events: { change: setDefault }"
									data-value-field="id"
									data-text-field="label"
								>
								</select>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Quantità</label>
							<div class="col-9">
								<input type="number" name="quantity" class="form-control" data-bind="value: detailForm.data.quotationItem.quantity" min="1" step="1" />
							</div>
						</div>

						<div class="form-group row pb-3">
							<label class="col-sm-3 control-label text-sm-end pt-2">Prezzo</label>
							<div class="col-sm-9">
								<div class="input-group">
									<input type="number" name="price" class="form-control" placeholder="" data-bind="value: detailForm.data.quotationItem.price.amount" />
									<span class="input-group-text">
										<i class="fas fa-euro-sign text-4"></i>
									</span>
								</div>
								<div id="price-error"></div>
							</div>
						</div>

						<div class="form-group row pb-3">
							<label class="col-sm-3 control-label text-sm-end pt-2">Descrizione</label>
                            <div class="col-sm-9">
								<div class="input-group">
									<textarea name="note" class="form-control" data-bind="value: detailForm.data.quotationItem.note" rows="4"></textarea>
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