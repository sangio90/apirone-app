<cfoutput>

    <div id="catalog-bundle-detail-modal" class="modal fade">

        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="catalog-bundle-detail-form">
                    
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                    
                    <div class="card-body">
                        <div class="row">

                            <div class="col-6">
                                <div class="form-group pb-3">
                                    <label class="col-form-label" for="catalog-bundle-desc">Markup %</label>
                                    <input class="form-control" name="name" id="name" 
                                        required
                                        data-rule-required="true"
                                        data-msg-required="Nome richiesto"
                                        data-bind="value: detailForm.data.name"
                                        >
                                </div>
                            </div>

                        </div>

					</div>
					
                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 d-flex justify-content-end">
                                <div class="status errors-counter mt-1 me-3"></div>
                                <button type="button" class="btn btn-default btn-sm me-2" data-bs-dismiss="modal">Chiudi</button>
                                #saveButton( bind="click:save", size="sm")#
                            </div>
                        </div>
                    </footer>

                </form>
            
            </div>
        </section>  

    </div>

</cfoutput>