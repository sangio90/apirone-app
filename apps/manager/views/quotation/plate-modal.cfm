<cfoutput>
    <div id="plate-modal-root" class="modal fade quotation-item-modal">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content">

                <form id="line-detail-form" method="POST" name="line-detail-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>
                        
                    <div class="card-body">

                        <!--- 
                            bundle / categorie
                        --->
                        <div class="mb-3 row">
                            <div class="col-1">    
                                <label class="col-sm-12 col-form-label text-start">Quantità</label>
                                <input class="form-control" type="number" data-bind="value: detailForm.data.quantity" min="1">
                            </div>
                            <div class="col-3">
                                <label class="col-sm-2 col-form-label">Linea</label>
                                <select id="plate-line" 
                                    required
                                    class="form-control"
                                    data-bind="source: lines, value: detailForm.data.product.line.id, events: { change: loadModels }" 
                                    data-value-field="id"
                                    data-text-field="name"
                                    >
                                </select>
                            </div>

                            <div class="col-4">
                                <label class="col-sm-2 col-form-label">Modello</label>
                                <select id="plate-model" 
                                    required
                                    class="form-control"
                                    data-bind="source: models, value: detailForm.data.product.model.id, events: { change: loadFinishes }"
                                    data-value-field="id"
                                    data-text-field="code"
                                    >
                                </select>
                            </div>

                            <div class="col-4">
                                <label class="col-sm-2 col-form-label">Finitura</label>
                                <select id="plate-finish" 
                                    required
                                    class="form-control"
                                    data-bind="source: finishes, value: detailForm.data.product.finish.id, events: { change: loadProduct }"
                                    data-value-field="id"
                                    data-text-field="name"
                                    >
                                </select>
                            </div>
                        </div>

                        <div class="mb-3 row">

                            <!--- 
                                albero
                            --->
                            <div class="col-2">

                                <nav>

                                    <ul class="nav nav-tabs" role="tablist" id="quotation-plate-product-items-tabs">
                                        <li class="nav-item show active">
                                            <a class="nav-link active" id="plate-product-items-but" data-bs-toggle="tab" 
                                                href="##plate-product-items-tab" role="tab" aria-controls="tab1" aria-selected="true">
                                                Placca
                                            </a>
                                        </li>
                                        <li class="nav-item">
                                            <a class="nav-link" id="plate-fruit-product-items-but" data-bs-toggle="tab" 
                                                href="##plate-fruit-product-items-tab" role="tab" aria-controls="tab2" aria-selected="true">
                                                Frutti <span>(<span data-bind="text: getFruitCount"></span>)</span>
                                            </a>
                                        </li>
                                    </ul>

                                </nav>

                                <div class="tab-content" id="quotation-nav-tab-content">

                                    <!--- plate ---->
                                    <div class="tab-pane fade show active" id="plate-product-items-tab" role="tabpanel" aria-labelledby="plate-product-items-but">
                                        <div class="text-end mb-2">
                                            <a href="##" data-bind="click: goToProduct" target="_blank">Vai al prodotto</a>
                                        </div>
								        <div id="quotation-plate-product-items" style="max-width: 100%">
                                            
                                        </div>
                                    </div>

                                    <!--- fruits ---->
                                    <div class="tab-pane" id="plate-fruit-product-items-tab" role="tabpanel" aria-labelledby="plate-fruit-product-items-but">
                                        <div class="text-end"><a href="##" data-bind="click:toggleFruits, text:toggleFruitsLabel" class="hand"></a></div>
								        <div id="quotation-plate-fruits-product-items" style="max-width: 100%">
                                            <div data-template="quotation-fruit-row-tmpl" data-bind="source: detailForm.data.fruits">
                                            </div>
                                            <div data-bind="invisible: getFruitCount" class="text-center mt-4">
                                                <h3 style="opacity: 0.5;">Nessun frutto ancora aggiunto</h3>
                                            </div>
                                        </div>
                                    </div>

                                </div>

                            </div>

                            <!--- 
                                designer placca
                            --->                            
                            <div class="col-8">
                                <div id="plate-designer-header" class="mb-2 pb-2">
                                    <div class="row">
                                        <div class="col-md-2 float-end">
                                            <select id="plate-orientation" 
                                                required
                                                class="form-control"
                                                data-bind="source: availableOrientations, value: detailForm.data.product.orientation, events: { change: changeOrientation }" 
                                                data-value-field="id"
                                                data-text-field="name"
                                                >
                                            </select>
                                        </div>    
                                        <div class="col-md-4">
                                            <input 
                                                type="text" 
                                                id="plate-fruit-suggest" 
                                                class="fruit-suggest-widget-input" 
                                                placeholder="Aggiungi un frutto...">
                                        </div>    
                                    </div>
                                </div>

                                <div id="plate-designer-root">
                                    <!--- Dynamically populated container --->
                                    <div class="plate-designer" id="plate-designer">
                                        <div class="plate-designer-canvas" id="plate-designer-canvas">
                                            <h1 style="opacity: 0.5;">Definisci le impostazioni in alto per iniziare</h1>
                                        </div>
                                    </div>
                                </div>                                
                            
                            </div>

                            <!--- 
                                dettaglio riga / pricing 
                            --->
                            <!----
                            <div class="col-2">
                                #view(view="quotation/item-plate-pricing", args={id="plate-quotation-item-pricing-box"})#
                            </div>
                            ---->
                            <div class="col-2">
                                <div class="h-100">

                                    <div class="row">

                                        <div class="col-6">
                                            <div class="mb-1">Speciale:</div>
                                            <div>
                                                <input class="form-check-input" type="checkbox"
                                                    name="special" 
                                                    data-bind="value: detailForm.data.special">
                                            </div>
                                        </div>

                                        <div class="col-6 mb-2">

                                            <div class="mb-1">Stato:</div>
                                            <div>
                                                <select name="status" class="form-control form-control-sm" id="input-price-status"
                                                    data-bind="value: detailForm.data.status, source: detailForm.itemStatuses"
                                                    data-value-field="id"
                                                    data-text-field="name"
                                                    >
                                                </select>
                                            </div>
                                        </div>

                                        <div class="col-12">
                                            <div class="row mb-2">
                                                <div class="col-4 mt-2">Posizione:</div>
                                                <div class="col-8">
                                                    <input class="form-control form-control-sm" name="position" 
                                                        placeholder="Posizione"
                                                        id="qt-plate-position-suggest"

                                                        data-text-field="code"
                                                        data-value-primitive="true"
                                                        data-bind="value: detailForm.data.position">
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-12 mb-2">
                                            <textarea class="form-control" name="notes" placeholder="Note" rows="4"
                                                data-bind="value: detailForm.data.note"></textarea>
                                        </div>

                                    </div>

                                    <div>
                                        #view(view="quotation/item-total-pricing", args={id="plate-quotation-item-pricing-box"})#
                                    </div>

                                </div>
                            </div>
                        </div>

                    </div>

                    <footer class="card-footer">    
                        <div class="row">
                            <div class="col-md-6 fs-10">
                                <div data-bind="visible: detailForm.data.id">
                                    ID: <span data-bind="text: detailForm.data.id"></span> - Creato: <span data-bind="text: detailForm.data.createdAt"></span>
                                </div>
                            </div>
                            <div class="col-md-6 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:save">
                                    <i class="fas fa-save"></i> Salva
                                </button>
                                <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                                <div class="save-status errors-counter mt-1 float-end me-3"></div>
                            </div>
                        </div>
                    </footer>

                </form>

            </div>
        </section>
    
    </div>

    #template( view="jstemplate/quotation/quotation-fruit-row-tmpl" )#
    #template( view="jstemplate/quotation/quotation-fruit-suggest-row-tmpl" )#

</cfoutput>