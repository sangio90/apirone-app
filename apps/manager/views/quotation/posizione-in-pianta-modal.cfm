<cfoutput>
    <div id="posizione-in-pianta-modal" class="modal fade posizione-in-pianta-modal" tabindex="-1">

        <section class="modal-dialog modal-xl">
            <div class="modal-content">

                <form id="line-detail-form">

                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title">
                        	Posizione in pianta
                        </h2>
                    </header>

                    <div class="card-body">
                        Vuoi posizionare in pianta?
                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-default btn-sm me-2 float-start" id="btn-no">No</button>
                                <button type="button" class="btn btn-primary btn-sm me-2 float-end" data-bs-dismiss="modal" id="btn-si">Sì</button>
                            </div>
                        </div>
                    </footer>

                </form>

            </div>
        </section>
    </div>
</cfoutput>
