<cfoutput>
    <div id="qt-export-products-result-modal-root" class="modal fade">
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <header class="card-header d-flex align-items-center justify-content-between">
                    <h2 class="card-title">Risultato esportazione articoli</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi"></button>
                </header>

                <div class="card-body">
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
