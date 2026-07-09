<cfoutput>
    <div id="model-config-modal" class="modal fade">

        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="model-config-form" method="POST" name="model-config-form">

                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:modelConfigModal.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>

                    <div class="card-body">

                        <cfset local.isPlaSeg = ( prc.category.getType().getId() EQ "PLA" || prc.category.getType().getId() EQ "SEG" )>
                        <cfset local.unit = local.isPlaSeg ? "mm" : "cm">

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Larghezza</label>
                            <div class="col-sm-10">
                                <div class="input-group">
                                    <input type="text" required class="form-control col-sm-4"
                                        name="width"
                                        maxlength="5"
                                        data-bind="value: modelConfigModal.data.width"
                                    >
                                    <div class="input-group-append">
                                        <span class="input-group-text">#local.unit#</span>
                                    </div>
                                </div>
                                <span id="width-error"></span>
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Altezza</label>
                            <div class="col-sm-10">
                                <div class="input-group">
                                    <input type="text" required class="form-control col-sm-4" name="height"
                                        data-msg-required="height"
                                        maxlength="125"
                                        data-bind="value: modelConfigModal.data.height">
                                    <div class="input-group-append">
                                        <span class="input-group-text">#local.unit#</span>
                                    </div>
                                </div>
                                <span id="height-error"></span>
                            </div>
                        </div>

                        <cfif !local.isPlaSeg>
                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Lunghezza</label>
                            <div class="col-sm-10">
                                <div class="input-group">
                                    <input type="text" required class="form-control col-sm-4" name="length"
                                        maxlength="10"
                                        data-bind="value: modelConfigModal.data.length">
                                    <div class="input-group-append">
                                        <span class="input-group-text">#local.unit#</span>
                                    </div>
                                </div>
                                <span id="length-error"></span>
                            </div>
                        </div>
                        </cfif>

					</div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:saveModelConfig">
                                    <i class="fas fa-save"></i> Salva
                                </button>
                                <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                                <div class="status errors-counter mt-1 float-end me-3"></div>
                            </div>
                        </div>
                    </footer>

                </form>

            </div>
        </section>

    </div>

</cfoutput>