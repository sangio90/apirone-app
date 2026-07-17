<cfoutput>
    <div id="print-modal-root" class="modal fade">
        
        <section class="modal-dialog modal-md">

            <div class="modal-content">

                <form id="print-form" method="POST" name="print-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title">Configurazione stampa preventivo</h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">
                        <div class="mb-3 row">
                            <div class="col-12">
                                <label class="col-sm-12 col-form-label text-start" id="print-label-parent">Report di stampa</label>
                                <select class="form-control me-3" 
                                    id="report"
                                    name="report"
                                    data-bind="source: detailForm.data.reports, value: detailForm.data.report, events: { change: toggleOptions }"
                                    data-value-field="id"
                                    data-text-field="name"
                                >
                                </select>
                            </div>
                        </div>
                        <div class="row mt-3">
                            <div class="col-6" id="qt-print-images-cont">
                                <label class="form-check-label">
                                    <input class="form-check-input ms-2 me-2" type="checkbox" id="qt-print-image-checkbox" name="images">
                                    Immagini
                                </label>
                            </div>
                            <div class="col-6" id="qt-print-grouped-cont">
                                <label class="form-check-label">
                                    <input class="form-check-input ms-2 me-2" type="checkbox" id="qt-print-grouped-checkbox" name="grouped">
                                    Raggruppamento
                                </label>
                            </div>
                        </div>
                        <div class="row mt-2">
                            <div class="col-6" id="qt-print-note-cont">
                                <label class="form-check-label">
                                    <input class="form-check-input ms-2 me-2" type="checkbox" id="qt-print-note-checkbox" name="note">
                                    Note
                                </label>
                            </div>
                            <div class="col-6" id="qt-print-discounts-cont">
                                <label class="form-check-label">
                                    <input class="form-check-input ms-2 me-2" type="checkbox" id="qt-print-discounts-checkbox" name="discounts">
                                    Sconti
                                </label>
                            </div>
                        </div>
                        <div class="row mt-2">
                            <div class="col-6" id="qt-print-hide-total-cont">
                                <label class="form-check-label">
                                    <input class="form-check-input ms-2 me-2" type="checkbox" id="qt-print-hide-total-checkbox" name="hideTotal">
                                    Nascondi totale
                                </label>
                            </div>
                        </div>
                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:print">
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