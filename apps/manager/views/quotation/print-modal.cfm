<cfoutput>
    <div id="print-modal-root" class="modal fade">
        
        <section class="modal-dialog modal-md">

            <div class="modal-content">

                <form id="print-form" method="POST" name="print-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title">Configurazione Stampa Preventivo</h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">
                        <div class="mb-3 row">
                            <div class="col-12">
                                <label class="col-sm-12 col-form-label text-start" id="print-label-parent">Tipo Stampa</label>
                                <select class="form-control me-3" 
                                    id="report"
                                    name="report"
                                    data-bind="source: detailForm.data.reports, value: detailForm.data.report, events: { change: toggleOptions }"
                                    data-value-field="id"
                                    data-text-field="name"
                                >
                                </select>
                            </div>
                            <div class="col-3" id="imagesDiv">    
                                <label class="col-sm-12 col-form-label text-start">Immagini</label>
                                <input class="form-check-input"
                                    type="checkbox" 
                                    id="imagesCheckbox"
                                    name="images"
                                >
                            </div>
                            <div class="col-3" id="groupedDiv">  
                                <label class="col-sm-12 col-form-label text-start">Raggruppamento</label>
                                <input class="form-check-input"
                                    type="checkbox" 
                                    id="groupedCheckbox"
                                    name="grouped"
                                >
                            </div>
                            <div class="col-3" id="notesDiv">     
                                <label class="col-sm-12 col-form-label text-start">Note</label>
                                <input class="form-check-input"
                                    type="checkbox" 
                                    id="notesCheckbox"
                                    name="notes"
                                >
                            </div>
                            <div class="col-3" id="discountsDiv">     
                                <label class="col-sm-12 col-form-label text-start">Sconti</label>
                                <input class="form-check-input"
                                    type="checkbox" 
                                    id="discountsCheckbox"
                                    name="discounts"
                                >
                            </div>
                        </div>
                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:printQuotation">
                                    <i class="fas fa-print"></i> Stampa
                                </button>
                                <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                            </div>
                        </div>
                    </footer>

                </form>

            </div>
        </section>
    
    </div>

</cfoutput>