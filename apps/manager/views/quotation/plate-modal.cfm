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
                                    data-bind="source: lines, value: detailForm.data.product.catalogBundle.line, events: { change: loadModels }" 
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
                                    data-bind="source: models, value: detailForm.data.product.catalogBundle.model, events: { change: loadFinishes }"
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
								<div id="quotation-plate-product-items" style="max-width: 100%"></div>
                            </div>

                            <div class="col-9" style="height:500px">

                                <div id="plate-designer-root">
                                    <div style="grid-column: 1 / 1; grid-row: 1 / 3; display: flex; flex-direction: column; width: 100%; align-items: stretch; z-index: 1;">
                                        <button
                                            type="button"
                                            data-bind="click: onClickGenerali">
                                            <div>
                                                <i class="fas fa-info-circle"></i>
                                            </div>
                                            Generali
                                        </button>

                                        <label>Lista placche</label>

                                        <div>
                                            <input
                                                data-role="dropdownlist"
                                                data-value-field="UUID"
                                                data-text-field="CODE"
                                                data-bind="source: plates, value: selectedPlate" />
                                        </div>

                                        <button
                                            type="button"
                                            data-bind="click: onClickConfigura">
                                            <div>
                                                <i class="fas fa-cogs"></i>
                                            </div>
                                            Configura
                                        </button>

                                        <button
                                            type="button"
                                            data-bind="click: onClickListaFrutti">
                                            <div>
                                                <i class="fas fa-list"></i>
                                            </div>
                                            Lista frutti
                                        </button>

                                        <button
                                            type="button"
                                            data-bind="click: onClickImmagine">
                                            <div>
                                                <i class="far fa-image"></i>
                                            </div>
                                            Immagine
                                        </button>
                                    </div>

                                    <div style="grid-column: 2 / 3; grid-row: 1 / 2; display: flex; width: 100%; align-items: center; justify-content: flex-end; z-index: 1;">
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

</cfoutput>