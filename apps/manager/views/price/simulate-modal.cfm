<cfoutput>

    <div id="price-simulate-modal" class="modal fade">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content">

                <form id="price-simulate-modal-form" method="POST" name="price-simulate-modal-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <!--- <h2 class="card-title" data-bind="text:title"></h2> --->
                        <h2 class="card-title">Calcolo prezzo</h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

						<div id="product-simulate-description">

						</div>

                        <!--- 
							<div class="mb-3 row" data-template="price-simulate-row-tmpl" data-bind="source: prices"> 
                        </div>
						---->
                    
                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                            </div>
                        </div>
                    </footer>

                </form>

            </div>
        </selection>
    
    </div>

</cfoutput>
