<cfoutput>
    <div id="plate-modal-root" class="modal fade">
        
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
                            <div class="col-4">
                                <label class="col-sm-2 col-form-label">Linea</label>
                                <select id="plate-line" 
                                    required
                                    class="form-control"
                                    data-bind="source: lines, value: detailForm.data.product.line, events: { change: loadModels }" 
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
                                    data-bind="source: models, value: detailForm.data.product.model, events: { change: loadFinishes }"
                                    data-value-field="id"
                                    data-text-field="name"
                                    >
                                </select>
                            </div>

                            <div class="col-4">
                                <label class="col-sm-2 col-form-label">Finitura</label>
                                <select id="plate-finish" 
                                    required
                                    class="form-control"
                                    data-bind="source: finishes, value: detailForm.data.product.finish , events: { change: loadProduct }"
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
                            <div class="col-3">    

                                <nav>

                                    <ul class="nav nav-tabs" role="tablist">
                                        <li class="nav-item active">
                                            <a class="nav-link active" id="plate-product-items-but" data-bs-toggle="tab" 
                                                href="##plate-product-items-tab" role="tab" aria-controls="tab1" aria-selected="true">
                                                Placca
                                            </a>
                                        </li>
                                        <li class="nav-item">
                                            <a class="nav-link" id="plate-fruit-product-items-but" data-bs-toggle="tab" 
                                                href="##plate-fruit-product-items-tab" role="tab" aria-controls="tab2" aria-selected="true">
                                                Frutti <span data-bind="text: getFruitsCount"></span>
                                            </a>
                                        </li>
                                    </ul>

                                </nav>

                                <div class="tab-content" id="quotation-nav-tabContent">

                                    <!--- plate ---->
                                    <div class="tab-pane fade show active" id="plate-product-items-tab" role="tabpanel" aria-labelledby="plate-product-items-but">
								        <div id="quotation-plate-product-items" style="max-width: 100%">
                                            
                                        </div>
                                    </div>

                                    <!--- fruits ---->
                                    <div class="tab-pane fade" id="plate-fruit-product-items-tab" role="tabpanel" aria-labelledby="plate-fruit-product-items-but">
								        <div id="quotation-plate-fruits-product-items" style="max-width: 100%">
                                            <div data-template="quotation-fruit-row-tmpl" data-bind="source: detailForm.data.fruits">
                                            </div>
                                        </div>
                                    </div>

                                </div>

                            </div>

                            <div class="col-9">

                                <div id="plate-designer-root">
                                    <div id="plate-designer-header" class="mb-2">
                                        <input 
                                            type="text" 
                                            id="plate-fruit-suggest" 
                                            class="search-widget-input" 
                                            placeholder="Aggiungi un frutto...">

                                        <!---
                                        <input
                                            data-role="dropdownlist"
                                            data-value-field="uuid"
                                            data-text-field="name"
                                            data-filter="contains"
                                            data-bind="source: fruits,
                                                    events: {
                                                        select: onSelectFruit
                                                    }"
                                            data-option-label="🔍 Cerca frutto..."
                                            style="width: 200px"/>
                                        ------>
                                    </div>

                                    <!--- Dynamically populated container --->
                                    <div class="plate-designer">
                                        <div style="width: 1200px; height: 500px; display: flex; align-items: center; justify-content: center;">
                                            <h1 style="opacity: 0.5;">Definire le impostazioni generali per iniziare</h1>
                                        </div>
                                    </div>
                                </div>                                
                            </div>
                        </div>

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
        </section>
    
    </div>

    #template( view="jstemplate/quotation/quotation-fruit-row-tmpl" )#
    #template( view="jstemplate/quotation/quotation-fruit-suggest-row-tmpl" )#

</cfoutput>