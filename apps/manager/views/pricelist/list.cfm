<cfoutput>
    <div id="pricelist-root">

        <div class="row">

            <div class="col-12">
                <h1>Listini</h1>
            </div>

            <div class="col-12">

                <div class="row">
                    <div class="mb-3 d-flex justify-content-start col-6">
                        <button type="button" class="btn btn-default btn-sm" data-bind="click:new">
                            <i class="fas fa-plus"></i> Nuovo listino
                        </button>
                    </div>
                </div>

                <div class="row d-none" id="pricelist-item">
                    <div class="col-12">
                        <form id="pricelist-detail-form">
                            <section class="card card-featured card-featured-primary mb-4">

                                <header class="card-header">
                                    <h2 class="card-title">Carica listino</h2>
                                </header>
                                
                                <div class="card-actions">
                                    <a href="##" class="card-action card-action-dismiss" data-dismiss="pricelist-item"></a>
                                </div>                                
                                <div class="card-body">
                                    <div class="row form-group pb-3">
                                        <div class="col-lg-12">
                                            <div class="form-group">
                                                <label class="col-form-label" for="pricelist-desc">Descrizione</label>
                                                <input type="text" class="form-control" id="pricelist-desc" name="name"
                                                    data-rule-required="true"
                                                    data-msg-required="Descrizione richiesta"
                                                >
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <footer class="card-footer text-end">
                                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:save">
                                        <i class="fas fa-save"></i> Carica
                                    </button>
                                </footer>
                            </section>
                        </form>
                    </div>
                </div>  


                <section class="card">
                    
                    <div class="card-body">

                        <form name="pricelist-grid-form" id="pricelist-grid-form" method="post">

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
                                id="pricelist-grid" 
                                data-bound="ZB.kendo.toggleScrollbar"
                                data-columns="[
                                    {'field':'name', 'title':'Descrizione',},
                                    {'field':'', 'title':'', width: '40px'}
                                ]" 
                                data-role="grid" 
                                data-sortable="true" 
                                data-editable="inline" 
                                data-bind="source: source" 
                                data-row-template="pricelist-grid-row-tmpl">
                            </div>

                        </form>
                    
                    </div>
                </section>
            </div>
        </div>

    </div>

    #template( view="jstemplates/pricelist-grid-row" )#

</cfoutput>