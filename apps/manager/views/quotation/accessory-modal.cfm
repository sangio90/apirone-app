<cfoutput>
    <div id="accessory-modal" class="modal fade" tabindex="-1">
        
        <section class="modal-dialog modal-xl">
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
                                    <select id="accessoryProductCategory" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la categoria"
                                        data-bind="source: categories, value: detailForm.data.quotationItem.product.catalogBundle.category, events: { change: loadLines }"
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-2" data-bind="visible: detailForm.data.quotationItem.product.catalogBundle.category.id">    
                                <label class="col-sm-2 col-form-label text-start">Linea</label>
                                <div class="col-sm-10">
                                    <select id="accessoryRow" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la linea"
                                        data-bind="source: lines, value: detailForm.data.quotationItem.product.catalogBundle.line, events: { change: loadModels }" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-2" data-bind="visible: detailForm.data.quotationItem.product.catalogBundle.line.id">    
                                <label class="col-sm-2 col-form-label text-start">Modello</label>
                                <div class="col-sm-10">
                                    <select id="accessoryModel" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona il modello"
                                        data-bind="source: models, value: detailForm.data.quotationItem.product.catalogBundle.model, events: { change: loadFinishes }" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            <div class="col-2" data-bind="visible: detailForm.data.quotationItem.product.catalogBundle.model.id">
                                <label class="col-sm-2 col-form-label text-start">Finitura</label>
                                <div class="col-sm-10">
                                    <select id="accessoryFinish" 
                                        class="form-control"
                                        data-placeholder="-- Seleziona la finitura"
                                        data-bind="source: finishes, value: detailForm.data.quotationItem.product.finish, events: { change: loadProduct }" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="mb-3 mt-4 row" data-bind="visible: detailForm.data.quotationItem.product.finish.id">
                            <div class="col-4 mb-3">
                                Albero
                            </div>
                            <div class="col-8 mb-3" data-bind="visible: detailForm.data.quotationItem.product.finish.id">
                                <span>Anteprima</span>
                            </div>
                            <div class="col-4 mb-3">
                                <div id="accessory-product-items" style="max-width: 100%"></div>
                            </div>
                            <div id="accessory-preview-background"
                                class="col-8 d-flex justify-content-center align-items-center"
                                data-bind="visible:detailForm.data.quotationItem.product.finish.id, style: { backgroundImage: backgroundImage.url, position: relative }"
                            >
                            </div>
                        </div>
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
    </div>
</cfoutput>