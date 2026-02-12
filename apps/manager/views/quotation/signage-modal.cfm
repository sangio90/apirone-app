<cfoutput>
    <div id="signage-modal" class="modal fade quotation-item-modal">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content">

                <form id="line-detail-form">

                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" data-bind="click:resetForm" aria-label="Chiudi"></button>
                    </header>                
                        
                    <div class="card-body">

                        <div class="mb-2 row">
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
                                        data-bind="source: finishes, value: detailForm.data.quotationItem.product.finish, events: { change: loadSignageConfigs }" 
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
                                        data-placeholder="-- Seleziona il font"
                                        data-bind="source: fonts, value: detailForm.data.signageConfig.font, events: { change: loadFontSizes }"
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-1" data-bind="visible: detailForm.data.signageConfig.font.id">    
                                <label class="col-sm-12 col-form-label text-start">Altezza font</label>
                                <div class="col-sm-12">
                                    <select id="signageFontSize" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona l'altezza del font"
                                        data-bind="source: detailForm.data.signageConfig.items, value: detailForm.data.quotationItem.signageConfigItem, events: { change: parseLines }" 
                                        data-value-field="id"
                                        data-text-field="sizeName"
                                        >
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div class="row mb-2 pb-2 bb-1">
                            <div class="col-12 text-end">
                                <a class="underline hand" data-bind="click:clearFilters, visible:visibleUpperClearButton">Pulisci configurazione</a>
                            </div>
                        </div>

                        <div class="mb-3 mt-3 row" data-bind="visible:detailForm.data.quotationItem.signageConfigItem.id">

                            <!--- 
                                albero
                            --->
                            <div class="col-2 mb-3">
                                <div id="product-items" style="max-width: 100%"></div>
                            </div>

                            <div class="col-4 mb-3" data-bind="visible:detailForm.data.signageConfig.font.id">
                                
                                <div class="flex justify-content-between mb-3">
                                    <span class="me-2">Righe</span>
                                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:addSignageRow, enabled:detailForm.data.quotationItem.signageConfigItem.id">Aggiungi Riga</button>
                                </div>

                                <div id="signage-rows-container" style="max-height: 600px; overflow-y: auto" data-template="signage-line-row-tmpl" data-bind="source: detailForm.data.quotationItem.signageRows, visible:detailForm.data.signageConfig.font.id">
                                    <!--- qui dentro vanno gli items --->
                                </div>

                            </div>
                            
                            <div class="col-4 mb-3" data-bind="visible:detailForm.data.signageConfig.font.id">
                                <i class="fas fa-question text-md mx-2" style="cursor: pointer" data-bind="events: { click: togglePictogramHelper }"></i>
                                <span>Anteprima</span>

                                <div id="quotation-signage-preview-background"
                                    class="col-3 d-flex justify-content-center align-items-center"
                                    data-bind="visible:detailForm.data.signageConfig.font.id, style: { backgroundImage: backgroundImage.url }">
                                    <div id="signage-preview-container"
                                        style="min-width: 100%"
                                        class="d-flex flex-column justify-content-center"
                                        data-template="signage-line-preview-row-tmpl"
                                        data-bind="source: detailForm.data.quotationItem.signageRows">
                                        <!-- qui dentro vanno gli items di preview -->
                                    </div>
                                </div>
                            </div>

                            <!--- 
                                dettaglio riga / pricing 
                            --->
                            <div class="col-2">
                                #view(view="quotation/item-pricing", args={id="signage-quotation-item-pricing-box"})#
                            </div>
                        </div>
                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-6">
                                <button type="button" class="btn btn-primary btn-sm" data-bind="click:clearFilters, visible:visibleLowerClearButton">Pulisci configurazione</button>
                            </div>

                            <div class="col-md-6 float-end">
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
            <div class="modal-dialog pictogram-helper-modal">
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
