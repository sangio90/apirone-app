
<cfoutput>

    <div id="combination-images-list-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="documents-form" name="documents-form" autocomplete="off">
                
                    <header class="card-header">
                        <h2 class="card-title">Carica immagini</h2>
                    </header>
                    
                    <div class="card-body">                

                        <!----
                        <div style="border: 1px solid ##EAEAEA; padding; 10px; height: 150px" class="mb-3">
                            <span style="color: ##CCCCCC">Versione orizzontale</span>
                        </div>

                        <div style="border: 1px solid ##EAEAEA; padding; 10px; height: 150px" class="mb-3">
                            <span style="color: ##CCCCCC">Versione verticale</span>
                        </div>
                        ---->

                        
                        <div class="row"
                            data-bind="source: images" 
                            data-template="combination-images-item-tmpl">
                        </div>
                        
                    
                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 text-end">
                                <button type="button" class="btn btn-primary btn-sm me-2 float-end disabled" 
                                    id="button-next-document"
                                    data-bind="css: { disabled: isDocumentsUploadUncompleted }, click: showPaymentDialog">Carica &raquo;
                                </button>
                                <div class="status errors-counter mt-2 error float-end clear-end me-3"></div>
                            </div>
                        </div>
                    </footer>                    
                
                </form>

            </div>
        </section>

        #template("jstemplate/combination/combination-images-item-tmpl")#
    
    </div>

</cfoutput>
