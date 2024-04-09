<cfoutput>
    <div id="option-root">

        <div class="row">

            <div class="col-12">
                <h1>Opzioni</h1>
            </div>

            <div class="col-12">

                <div class="row">
                    <div class="mb-3 d-flex justify-content-start col-6">
                        <button type="button" class="btn btn-default btn-sm" data-bind="click:new">
                            <i class="fas fa-plus"></i> Nuova opzione
                        </button>
                    </div>
                </div>

                <div class="row d-none" id="option-item">
                    <div class="col-12">
                        <form id="option-detail-form">
                            <section class="card card-featured card-featured-primary mb-4">

                                <header class="card-header">
                                    <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                                </header>
                                
                                <div class="card-actions">
                                    <a href="##" class="card-action card-action-dismiss" data-dismiss="option-item"></a>
                                </div>                                
                                <div class="card-body">
                                    <div class="row form-group pb-3">
                                        <div class="col-lg-12">
                                            <div class="row">
                                                
                                                <div class="col-3">
                                                    <div class="form-group pb-3">
                                                        <label class="col-form-label" for="option-desc">ID</label>
                                                        <input type="text" class="form-control" name="id" maxlength="5"
                                                            data-plugin-maxlength
                                                            data-bind="value: detailForm.data.id, disabled: detailForm.isIdDisabled"
                                                            onkeyup="this.value = this.value.toUpperCase();"
                                                        >
                                                    </div>
                                                </div>
                                                <div class="col-9">
                                                    <div class="form-group pb-3">
                                                        <label class="col-form-label" for="option-desc">Descrizione</label>
                                                        <input type="text" class="form-control" name="name"
                                                            data-bind="value: detailForm.data.name"
                                                        >
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="col-3">
                                                    <div class="form-group pb-3">
                                                        <label class="col-form-label" for="option-desc">Bottiglie</label>
                                                        <input type="text" class="form-control" name="quantity"
                                                            data-bind="value: detailForm.data.quantity"
                                                        >
                                                    </div>
                                                </div>

                                                <div class="col-3">
                                                    <div class="form-group pb-3">
                                                        <label class="col-form-label" for="option-desc">Tipo prezzo</label>
                                                        <select type="text" class="form-control" name="priceType"
                                                            data-bind="value: detailForm.data.price.type.id, events: { change: changePriceType }"
                                                        >
                                                            <option value="F">Fisso</option>
                                                            <option value="P">%</option>
                                                        </select>
                                                    </div>
                                                </div>

                                                <div class="col-3">
                                                    <div class="form-group pb-3">
                                                        <label class="col-form-label" for="option-desc">Prezzo</label>
                                                        <div>
                                                            <div class="input-group">
                                                                <input name="price" class="form-control"
                                                                    data-bind="value: detailForm.data.price.value"
                                                                >
                                                                <span class="input-group-text">
                                                                    <i class="fa-solid" data-bind="css: { fa-euro-sign: detailForm.isFixedPrice, fa-percent: detailForm.isPercPrice }"></i>
                                                                </span>
                                                            </div>
                                                        </div>
                                                        <div id="price-error"></div>
                                                    </div>
                                                </div>


                                                <div class="col-3">
                                                    <div class="form-group pb-3">
                                                        <label class="col-form-label" for="option-desc">Disponibile in</label>
                                                        <cfloop array="#prc.types#" index="item">
                                                            <div class="checkbox">
                                                                <label>
                                                                    <input type="checkbox" value="#item.getId()#" name="types"
                                                                        data-bind="checked: detailForm.selectedTypes"
                                                                    >
                                                                    #item.getName()#
                                                                </label>
                                                            </div>
                                                        </cfloop>

                                                        <div id="types-error"></div>
    
                                                    </div>
                                                </div>
                                            </div>

                                        </div>
                                    </div>
                                </div>
                                <footer class="card-footer text-end">
                                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:save">
                                        <i class="fas fa-save"></i> <span data-bind="text:detailForm.label"></span>
                                    </button>

                                </footer>
                            </section>
                        </form>
                    </div>
                </div>  


                <section class="card">
                    
                    <div class="card-body">

                        <form name="option-grid-form" id="option-grid-form" method="post">

                            <div class="row">
                                <div class="mb-3 d-flex justify-content-end col-12">
                                    <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:deleteAll">
                                        <i class="fas fa-remove"></i> Cancella selezionati
                                    </button>
                                    <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:print">
                                        <i class="fas fa-print"></i> Stampa
                                    </button>
                                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:saveAll">
                                        <i class="fas fa-save"></i> Salva tutto
                                    </button>
                                </div>
                            </div>
                            
                            <div 
                                id="option-grid" 
                                data-bound="ZB.kendo.toggleScrollbar"
                                data-columns="[
                                    { 'field':'id', 'title':'ID', width: '80px' },
                                    { 'field':'name', 'title':'Descrizione'},
                                    { 'field':'quantity', 'title':'Bottiglie', width: '120px'},
                                    { 'field':'price', 'title':'Prezzo', width: '250px'},
                                    { 'field':'', 'title':'', width: '60px'},
                                    { 'field':'', 'title':'', width: '40px'}
                                ]" 
                                data-role="grid" 
                                data-sortable="true" 
                                data-editable="inline" 
                                data-bind="source: rows" 
                                data-row-template="option-grid-row-tmpl">
                            </div>

                        </form>
                    
                    </div>
                </section>
            </div>
        </div>

    </div>

    #template( view="jstemplates/option-grid-row" )#

</cfoutput>