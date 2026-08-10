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

                        <!--- 1. Tipologia di stampa --->
                        <div class="mb-4">
                            <label class="col-form-label text-start fw-bold pt-0" id="print-label-parent">1. Tipologia di stampa</label>
                            <div class="btn-group w-100" role="group" aria-label="Tipologia di stampa">
                                <input type="radio" class="btn-check" name="report" id="qt-print-type-classic" value="classic" autocomplete="off" checked>
                                <label class="btn btn-outline-primary btn-sm" for="qt-print-type-classic">Classica</label>

                                <input type="radio" class="btn-check" name="report" id="qt-print-type-photo" value="photo" autocomplete="off">
                                <label class="btn btn-outline-primary btn-sm" for="qt-print-type-photo">Foto</label>

                                <input type="radio" class="btn-check" name="report" id="qt-print-type-technical" value="technical" autocomplete="off">
                                <label class="btn btn-outline-primary btn-sm" for="qt-print-type-technical">Tecnica</label>

                                <input type="radio" class="btn-check" name="report" id="qt-print-type-proforma" value="proforma" autocomplete="off">
                                <label class="btn btn-outline-primary btn-sm" for="qt-print-type-proforma">Proforma</label>
                            </div>
                        </div>

                        <!--- Dati proforma: visibili solo per la tipologia Proforma --->
                        <div class="mb-4" id="qt-print-proforma-cont">
                            <label class="col-form-label text-start fw-bold pt-0">Dati proforma</label>
                            <div class="row">
                                <div class="col-6">
                                    <label class="form-label small mb-1" for="qt-print-proforma-progressivo">Progressivo proforma</label>
                                    <input type="text" class="form-control form-control-sm"
                                        id="qt-print-proforma-progressivo" name="progressivo"
                                        maxlength="10" placeholder="es. 01" autocomplete="off">
                                </div>
                                <div class="col-6">
                                    <label class="form-label small mb-1" for="qt-print-proforma-percentuale">Percentuale anticipo</label>
                                    <div class="input-group input-group-sm">
                                        <input type="number" class="form-control"
                                            id="qt-print-proforma-percentuale" name="percentuale"
                                            min="0" max="100" step="0.01" placeholder="es. 30" autocomplete="off">
                                        <span class="input-group-text">%</span>
                                    </div>
                                </div>
                            </div>
                            <div class="text-danger small mt-2 d-none" id="qt-print-proforma-error"></div>
                        </div>

                        <!--- 2. Raggruppamento --->
                        <div class="mb-4" id="qt-print-grouping-cont">
                            <label class="col-form-label text-start fw-bold pt-0">2. Raggruppamento</label>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="grouping" id="qt-print-grouping-categories" value="categories">
                                <label class="form-check-label" for="qt-print-grouping-categories">
                                    Raggruppa per categorie
                                    <span class="text-muted small">(placche, frutti, segnaletica, accessori)</span>
                                </label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="grouping" id="qt-print-grouping-none" value="none">
                                <label class="form-check-label" for="qt-print-grouping-none">
                                    Tutte insieme
                                    <span class="text-muted small">(elenco unico, senza intestazioni di categoria)</span>
                                </label>
                            </div>
                        </div>

                        <!--- 3. Cosa stampare --->
                        <div>
                            <label class="col-form-label text-start fw-bold pt-0">3. Cosa stampare</label>
                            <div class="row">
                                <div class="col-6" id="qt-print-images-cont">
                                    <label class="form-check-label">
                                        <input class="form-check-input ms-2 me-2" type="checkbox" id="qt-print-image-checkbox" name="images">
                                        Immagini
                                    </label>
                                </div>
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
                                <div class="col-6" id="qt-print-plants-cont">
                                    <label class="form-check-label">
                                        <input class="form-check-input ms-2 me-2" type="checkbox" id="qt-print-plants-checkbox" name="plants">
                                        Piante
                                    </label>
                                </div>
                                <div class="col-6" id="qt-print-hide-total-cont">
                                    <label class="form-check-label">
                                        <input class="form-check-input ms-2 me-2" type="checkbox" id="qt-print-hide-total-checkbox" name="hideTotal">
                                        Nascondi totale
                                    </label>
                                </div>
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
