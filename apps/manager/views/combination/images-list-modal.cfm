
<cfoutput>

    <div id="line-images-list-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="documents-form" name="documents-form" autocomplete="off">
                
                    <header class="card-header">
                        <h2 class="card-title">Carica i documenti richiesti</h2>
                    </header>
                    
                    <div class="card-body">                

                        <div class="row"
                            data-bind="source: documents" 
                            data-template="shipment-document-item-tmpl">
                        </div>
                    
                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 text-end">
                                <button type="button" class="btn btn-primary btn-sm me-2 float-end disabled" 
                                    id="button-next-document"
                                    data-bind="css: { disabled: isDocumentsUploadUncompleted }, click: showPaymentDialog">Vai al pagamento &raquo;
                                </button>
                                <div class="status errors-counter mt-2 error float-end clear-end me-3"></div>
                                <p>Per proseguire caricare i documenti richiesti.</p>
                            </div>
                        </div>
                    </footer>                    
                
                </form>

            </div>
        </section>
    
    </div>

</cfoutput>
