<cfoutput>
    <div id="signage-modal" class="modal fade">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content">

                <form id="line-detail-form" method="POST" name="line-detail-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

                        <div class="mb-3 row">
                            <div class="col-3">
                                <label class="col-sm-2 col-form-label text-start">Categoria</label>
                                <div class="col-sm-10">
                                    <select id="signangeProductCategory" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la categoria"
                                        data-bind="source: categories, value: detailForm.data.category.id, events: { change: loadLines }"
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-3">    
                                <label class="col-sm-2 col-form-label text-start">Linea</label>
                                <div class="col-sm-10">
                                    <select id="signageLine" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la linea"
                                        data-bind="source: lines, value: detailForm.data.line.id, events: { change: loadModels }" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        disabled="disabled"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-3">    
                                <label class="col-sm-2 col-form-label text-start">Modello</label>
                                <div class="col-sm-10">
                                    <select id="signageModel" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona il modello"
                                        data-bind="source: models, value: detailForm.data.model.id, events: { change: loadFinishes }" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        disabled="disabled"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-3">    
                                <label class="col-sm-2 col-form-label text-start">Finitura</label>
                                <div class="col-sm-10">
                                    <select id="signageFinish" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la finitura"
                                        data-bind="source: finishes, value: detailForm.data.finish.id, events: { change: loadSignageConfigs }" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        disabled="disabled"
                                        >
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="mb-3 row">
                            <div class="col-6">    
                                <label class="col-sm-2 col-form-label text-start">Font</label>
                                <div class="col-sm-10">
                                    <select id="signageFont" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la font"
                                        data-bind="source: fonts, value: detailForm.data.font.id" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        disabled="disabled"
                                        >
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="mb-3 row">
                            <div class="col-12" data-template="signage-line-row-tmpl" data-bind="source: detailForm.data.lines">
                                <!--- qui dentro vanno gli items --->
                            </div>
                        </div>
                        <button data-bind="click:addLine">Aggiungi Riga</button>
                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:save">
                                    <i class="fas fa-save"></i> Salva
                                </button>
                                <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                                <div class="status errors-counter mt-1 float-end me-3"></div>
                            </div>
                        </div>
                    </footer>

                </form>

            </div>
        </selection>
    
    </div>
    #template( view="jstemplate/quotation/signage-line-row-tmpl" )#
</cfoutput>