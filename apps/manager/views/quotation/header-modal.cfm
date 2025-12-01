<cfoutput>
    <div id="quotation-header-modal" class="modal fade">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content" id="quotation-header-root">

                <form id="quotation-header-form" method="POST" name="quotation-header-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text: detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

						#view( "quotation/header-form" )#

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
