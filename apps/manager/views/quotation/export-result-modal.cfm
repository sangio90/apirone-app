<cfoutput>
    <!---
        Riepilogo dell'esportazione verso Verticale:
        cosa è stato scritto del preventivo ( testata e righe di ORDINI_APIR ) e
        quali articoli sono stati esportati o erano già presenti. Il contenuto lo
        riempie app-quotation-detail.js ( renderExportResult ).
    --->
    <div id="qt-export-result-modal-root" class="modal fade">
        <section class="modal-dialog modal-xl">
            <div class="modal-content">

                <header class="card-header d-flex align-items-center justify-content-between">
                    <h2 class="card-title" id="qt-export-result-title">Risultato esportazione</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi"></button>
                </header>

                <div class="card-body">
                    <h5>Preventivo</h5>
                    <div id="qt-export-quotation" class="mb-4"></div>

                    <h5>Articoli</h5>
                    <div id="qt-export-products-exported" class="mb-3"></div>
                    <div id="qt-export-products-skipped"></div>
                </div>

                <footer class="card-footer">
                    <div class="d-flex justify-content-end">
                        <button type="button" class="btn btn-default btn-sm" data-bs-dismiss="modal">Chiudi</button>
                    </div>
                </footer>

            </div>
        </section>
    </div>
</cfoutput>
