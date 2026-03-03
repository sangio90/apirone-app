<cfoutput>
    <div id="zones-modal-root" class="modal fade">
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <header class="card-header d-flex align-elements-center justify-content-between">
                    <h2 class="card-title">Zone preventivo</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi"></button>
                </header>

                <div class="card-body">
                    <div>
                        #button( type="button", bind="click:addZone", class="mb-2", size="sm", label="Aggiungi Zona", icon="plus" )#
                    </div>
                    #grid( 
                        id="zones-grid",
                        class="no-pager",
                        columns="[
                            { 'field':'', 'title':'', width: '200px'},
                            { 'field':'name', 'title':'Nome', 'sortable': 'true'},
                            { 'field':'origin.name', 'title':'Zona Padre', 'sortable': 'true'},
                            { 'field':'quantity', 'title':'Quantità', 'sortable': 'false'},
                        ]",
                        source="detailForm.zones",
                        rowTemplate="quotation/zones-grid-row-tmpl"
                    )#
                </div>

                <footer class="card-footer">    
                    <div class="row">
                        <div class="col-md-12 float-end">
                            <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                            <div class="save-status errors-counter mt-1 float-end me-3"></div>
                        </div>
                    </div>
                </footer>
            </div>
        </section>
    </div>

    <div id="duplicateDialog" class="modal fade" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">

                <div class="modal-header">
                    <h5 class="modal-title" id="duplicateDialogTitle">Duplica Zona</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Nome nuova zona</label>
                        <input type="text"
                            id="duplicateNameInput"
                            class="form-control" />
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button"
                            class="btn btn-secondary"
                            data-bs-dismiss="modal">
                        Annulla
                    </button>

                    <button type="button"
                            class="btn btn-primary"
                            id="duplicateSimpleBtn">
                        Duplica
                    </button>

                    <button type="button"
                            class="btn btn-primary"
                            id="duplicateWithChildrenBtn">
                        Duplica con Sottozone
                    </button>
                </div>

            </div>
        </div>
    </div>

    #template( view="jstemplate/quotation/zones-grid-row-tmpl" )#
    #view( "quotation/zone-modal" )#
</cfoutput>