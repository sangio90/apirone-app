<cfoutput>
    <div id="zone-modal-root" class="modal fade">
        
        <section class="modal-dialog modal-lg">

            <div class="modal-content">

                <form id="zone-form" method="POST" name="zone-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" id="zoneTitle"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">
                        <div class="mb-3 row">
                            <div class="col-4">
                                <label class="col-sm-12 col-form-label text-start" id="zone-label-parent">Zona</label>
                                <select class="form-control me-3" 
                                    id="parentId"
                                    name="parentId"
                                    data-bind="source: zones, value: detailForm.data.parentZone"
                                    data-value-field="id"
                                    data-text-field="name"
                                >
                                </select>
                            </div>
                            <div class="col-4" id="zone-name-input">    
                                <label class="col-sm-12 col-form-label text-start">Nome</label>
                                <input class="form-control" 
                                    type="text" 
                                    id="zoneName"
                                    name="name"
                                    data-bind="value: detailForm.data.name">
                            </div>
                            <div class="col-4" id="zone-quantity-input">    
                                <label class="col-sm-12 col-form-label text-start">Quantità</label>
                                <input class="form-control" 
                                    type="text" 
                                    id="zoneQuantity"
                                    name="quantity"
                                    data-bind="value: detailForm.data.quantity">
                            </div>
                        </div>
                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" id="add-zone-button" class="btn btn-primary btn-sm float-end" data-bind="click:createZone">
                                    <i class="fas fa-save"></i> Salva
                                </button>
                                <button type="button" id="duplicate-zone-button" class="btn btn-primary btn-sm float-end" data-bind="click:duplicateZone">
                                    <i class="fas fa-copy"></i> Duplica
                                </button>
                                <button type="button" id="duplicate-zone-with-children-button" class="btn btn-primary btn-sm me-2 float-end" data-bind="click:duplicateZone">
                                    <i class="fas fa-copy"></i> Duplica con Sottozone
                                </button>
                                <button type="button" id="delete-zone-button" class="btn btn-danger btn-sm float-end" data-bind="click:deleteZone">
                                    <i class="fas fa-trash"></i> Elimina
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