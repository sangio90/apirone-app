<cfoutput>
    <div id="signage-modal" class="modal fade" tabindex="-1">
        
        <section class="modal-dialog modalxl">
            <div class="modal-content">

                <form id="line-detail-form">
                
                    <header class="card-header d-flex justify-content-between">
                        <h5 data-bind="text:detailForm.title"></h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" data-bind="click:resetForm" aria-label="Chiudi"></button>
                    </header>                
                        
                    <div class="card-body">

                        <div class="mb-3 row">
                            <div class="col-1">    
                                <label class="col-sm-12 col-form-label text-start">Quantità</label>
                                <input class="form-control" type="number" data-bind="value: detailForm.data.quotationItem.quantity" min="1">
                            </div>
                            <div class="col-2">
                                <label class="col-sm-2 col-form-label text-start">Categoria</label>
                                <div class="col-sm-10">
                                    <select id="signangeProductCategory" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la categoria"
                                        data-bind="source: categories, value: detailForm.data.signageConfig.catalogBundle.category, events: { change: loadLines }"
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-2" data-bind="visible: detailForm.data.signageConfig.catalogBundle.category.id">    
                                <label class="col-sm-2 col-form-label text-start">Linea</label>
                                <div class="col-sm-10">
                                    <select id="signageRow" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la linea"
                                        data-bind="source: lines, value: detailForm.data.signageConfig.catalogBundle.line, events: { change: loadModels }" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-2" data-bind="visible: detailForm.data.signageConfig.catalogBundle.line.id">    
                                <label class="col-sm-2 col-form-label text-start">Modello</label>
                                <div class="col-sm-10">
                                    <select id="signageModel" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona il modello"
                                        data-bind="source: models, value: detailForm.data.signageConfig.catalogBundle.model, events: { change: loadFinishes }" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-2" data-bind="visible: detailForm.data.signageConfig.catalogBundle.model.id">    
                                <label class="col-sm-2 col-form-label text-start">Finitura</label>
                                <div class="col-sm-10">
                                    <select id="signageFinish" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la finitura"
                                        data-bind="source: finishes, value: detailForm.data.quotationItem.product.finish.id, events: { change: loadSignageConfigs }" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-2" data-bind="visible: detailForm.data.quotationItem.product.finish.id">    
                                <label class="col-sm-2 col-form-label text-start">Font</label>
                                <div class="col-sm-10">
                                    <select id="signageFont" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la font"
                                        data-bind="source: fonts, value: detailForm.data.signageConfig.font, events: { change: loadFontSizes }"
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-1" data-bind="visible: detailForm.data.signageConfig.font.id">    
                                <label class="col-sm-12 col-form-label text-start">Dimensione Font</label>
                                <div class="col-sm-12">
                                    <select id="signageFontSize" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la dimensione del font"
                                        data-bind="source: fontSizes, value: detailForm.data.quotationItem.signageConfigItem, events: { change: parseLines }" 
                                        data-value-field="id"
                                        data-text-field="height"
                                        >
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="mb-3 mt-3 row" data-bind="visible:detailForm.data.quotationItem.signageConfigItem.id">
                            <div class="col-2 mb-3">
                                Albero
                            </div>
                            <div class="col-3 mb-3" data-bind="visible:detailForm.data.signageConfig.font.id">
                                Righe
                            </div>
                            <div class="col-3 mb-3 flex justify-content-end align-items-end">
                                <!--- <i class="fas fa-question text-md mx-2" style="cursor: pointer" data-bind="events: { click: togglePictogramHelper }"></i> --->
                                <i class="fas fa-question text-md mx-2" style="cursor: pointer" data-bind="events: { click: togglePictogramHelper }"></i>
                            </div>
                            <div class="col-4 mb-3" data-bind="visible:detailForm.data.signageConfig.font.id">
                                Anteprima
                            </div>
                            <div class="col-2 mb-3">
                                Albero
                            </div>
                            <div id="signage-rows-container" class="col-6" style="max-height: 400px; overflow-y: auto" data-template="signage-line-row-tmpl" data-bind="source: detailForm.data.quotationItem.signageRows, visible:detailForm.data.signageConfig.font.id">
                                <!--- qui dentro vanno gli items --->
                            </div>
                            <div class="col-4" data-template="signage-line-preview-row-tmpl" data-bind="source: detailForm.data.quotationItem.signageRows, visible:detailForm.data.signageConfig.font.id">
                                <!--- qui dentro vanno gli items di preview --->
                            </div>
                        </div>
                        <button type="button" class="btn btn-primary btn-sm" data-bind="click:addSignageRow, enabled:detailForm.data.quotationItem.signageConfigItem.id">Aggiungi Riga</button>
                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:save, enabled:canSave">
                                    <i class="fas fa-save"></i> Salva
                                </button>
                                <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal" data-bind="click:resetForm">Chiudi</button>
                                <div class="status errors-counter mt-1 float-end me-3"></div>
                            </div>
                        </div>
                    </footer>

                </form>

            </div>
        </section>
        <div class="modal fade" tabindex="-1" id="pictogram-helper-modal" data-bs-backdrop="true">
            <div class="modal-dialog" style="position: fixed; left: calc(50% + 400px); top: 20px; z-index: 200;">
                <div class="modal-content" style="width: 300px;">
                    <div class="modal-header">
                        <h5 class="modal-title">Elenco pittogrammi</h5>
                    </div>
                    <div class="text-center px-2 mt-1" style="font-size: 11px">Inserendo queste parole contornate da "<" e ">", verranno inseriti i pittogrammi nella riga.</div>
                    <div class="modal-body" data-bind="source: parsedPictograms" data-template="pictogram-template">
                        <script id="pictogram-template" type="text/x-kendo-template">
                            <div class="row text-center p-3">
                                <div class="col-3">##= data.label ##</div>
                                <div class="col-3">##= data.image ##</div>                            
                            </div>
                        </script>
                    </div>
                </div>
            </div>
        </div>
    </div>
    #template( view="jstemplate/quotation/signage-line-row-tmpl" )#
    #template( view="jstemplate/quotation/signage-line-preview-row-tmpl" )#
</cfoutput>