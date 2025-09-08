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
                            <div class="col-2">
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
                            <div class="col-2" data-bind="visible: detailForm.data.category.id">    
                                <label class="col-sm-2 col-form-label text-start">Linea</label>
                                <div class="col-sm-10">
                                    <select id="signageLine" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la linea"
                                        data-bind="source: lines, value: detailForm.data.line.id, events: { change: loadModels }" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-2" data-bind="visible: detailForm.data.line.id">    
                                <label class="col-sm-2 col-form-label text-start">Modello</label>
                                <div class="col-sm-10">
                                    <select id="signageModel" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona il modello"
                                        data-bind="source: models, value: detailForm.data.model.id, events: { change: loadFinishes }" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-2" data-bind="visible: detailForm.data.model.id">    
                                <label class="col-sm-2 col-form-label text-start">Finitura</label>
                                <div class="col-sm-10">
                                    <select id="signageFinish" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la finitura"
                                        data-bind="source: finishes, value: detailForm.data.finish.id, events: { change: loadSignageConfigs }" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-2" data-bind="visible: detailForm.data.finish.id">    
                                <label class="col-sm-2 col-form-label text-start">Font</label>
                                <div class="col-sm-10">
                                    <select id="signageFont" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la font"
                                        data-bind="source: fonts, value: detailForm.data.font, events: { change: loadFontSizes }" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-2" data-bind="visible: detailForm.data.font.id">    
                                <label class="col-sm-12 col-form-label text-start">Dimensione Font</label>
                                <div class="col-sm-12">
                                    <select id="signageFontSize" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la dimensione del font"
                                        data-bind="source: fontSizes, value: detailForm.data.fontSize, events: { change: parseLines }" 
                                        data-value-field="id"
                                        data-text-field="height"
                                        >
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="mb-3 mt-3 row">
                            <div class="col-2 mb-3">
                                Albero
                            </div>
                            <div class="col-3 mb-3" data-bind="visible:detailForm.data.font.id">
                                Righe
                            </div>
                            <div class="col-3 mb-3 flex justify-content-end align-items-end">
                                <i class="fas fa-question text-md mx-2" style="cursor: pointer" data-bind="events: { click: togglePictogramHelper }"></i>
                            </div>
                            <div class="col-4 mb-3" data-bind="visible:detailForm.data.font.id">
                                Anteprima
                            </div>
                            <div class="col-2 mb-3">
                                Albero
                            </div>
                            <div class="col-6" style="max-height: 400px; overflow-y: auto" data-template="signage-line-row-tmpl" data-bind="source: detailForm.data.signageLines, visible:detailForm.data.font.id">
                                <!--- qui dentro vanno gli items --->
                            </div>
                            <div class="col-4" data-template="signage-line-preview-row-tmpl" data-bind="source: detailForm.data.signageLines, visible:detailForm.data.font.id">
                                <!--- qui dentro vanno gli items di preview --->
                            </div>
                        </div>
                        <button type="button" class="btn btn-primary btn-sm" data-bind="click:addSignageLine, visible:detailForm.data.font.id">Aggiungi Riga</button>
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
        <div class="modal hide fade" tabindex="-1" id="pictogram-helper-modal">
            <div style="width: 100vw; height: 100vh; position: absolute; top: 0; left: 0;">
                <div class="modal-dialog" style="position: fixed; left: calc(50% + 300px); top: 20px; z-index: 1001;">
                    <div class="modal-content" style="width: 300px;">
                    <div class="modal-header">
                        <h3 class="modal-title">Elenco pittogrammi</h3>
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