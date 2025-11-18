<cfoutput>
    <div id="product-clone-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="product-clone-form" method="POST" name="product-clone-form" data-bind="events: { submit: clone }">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title">Copia l'albero del prodotto</h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

						<div class="row">
							<div class="col-sm-12">

								<div class="mb-3 row">
									<label class="col-sm-2 col-form-label text-end">Dal prodotto</label>
									<div class="col-sm-10">
										<span data-bind="text: cloneForm.fromProductId"></span>
									</div>
								</div>

								<div class="mb-3 row">
									<label class="col-sm-2 col-form-label text-end">Al prodotto</label>
									<div class="col-sm-10">
										<input id="toProductId" class="form-control" name="toProductId" plaeceholder="ID prodotto di destinazione (36 caratteri)"
                                            data-bind="value: cloneForm.toProductId">
									</div>
								</div>

								<div class="mb-3 row">
									<label class="col-sm-2"></label>
									<div class="col-md-10">
										<div class="alert alert-danger">
											<b>Attenzione</b>: tutti i dati (albero e relativi componenti) del prodotto di destinazione verranno eliminati e non potranno essere recuperati.
										</div>
									</div>
								</div>

							</div>
						</div>

                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:clone">
                                    <i class="fas fa-save"></i> Clona
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