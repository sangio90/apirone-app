<cfoutput>

    <div id="product-sorting-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <header class="card-header d-flex align-elements-center justify-content-between">
                    <h2 class="card-title">Riordina elementi</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                </header>

                <nav>

                    <ul class="nav nav-tabs" role="tablist">
                        <li class="nav-item active">
                            <a class="nav-link active" id="product-sorting-nav-values-but" data-bs-toggle="tab" 
                                href="##product-sorting-nav-values-tab" role="tab" aria-controls="tab1" aria-selected="true">
                                Valori
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" id="product-sorting-nav-attributes-but" data-bs-toggle="tab" 
                                href="##product-sorting-nav-attributes-tab" role="tab" aria-controls="tab2" aria-selected="true">
                                Attributi
                            </a>
                        </li>
                        <div class="tab-status">
                        </div>
                    </ul>

                </nav>

                <div class="card-body">

                    <div class="tab-content" id="nav-tabContent">

                        <div class="tab-pane fade show active" id="product-sorting-nav-values-tab" role="tabpanel" aria-labelledby="product-sorting-nav-values-tab">              
                    
                            <form id="product-sorting-modal-form" name="product-sorting-modal-form" autocomplete="off">
                            
                                <div class="col-12 text-end mb-2" id="product-sorting-status">
                                </div>
                                
                                <div class="col-12">

                                    #grid(
                                        id      = "product-ordering-items-grid",
                                        class   = "no-pager",
                                        columns = "[
                                            { 'field':'Id', 'title':'ID', width: '60px' },
                                            { 'field':'name', 'title':'Attributo/Valore' },
                                            { 'field':'', 'title':'Riordina', width: '55px'},
                                        ]",
                                        source: "orderingItems",
                                        rowTemplate = "product/product-ordering-item-row-tmpl"
                                    )#

                                </div>

                            </form>

                        </div>
                        
                        <div class="tab-pane fade show" id="product-sorting-nav-attributes-tab" role="tabpanel" aria-labelledby="product-sorting-nav-values-tab">              

                            <form id="product-sorting-attribute-modal-form" name="product-sorting-attribute-modal-form" autocomplete="off">
                            
                                <div class="col-12 text-end mb-2" id="product-sorting-attribute-status">
                                </div>
                                
                                <div class="col-12">

                                    #grid(
                                        id      = "product-ordering-attributes-grid",
                                        class   = "no-pager",
                                        columns = "[
                                            { 'field':'Id', 'title':'ID', width: '60px' },
                                            { 'field':'name', 'title':'Attributo' },
                                            { 'field':'', 'title':'Riordina', width: '55px'},
                                        ]",
                                        source: "orderingAttributes",
                                        rowTemplate = "product/product-ordering-attribute-row-tmpl"
                                    )#

                                </div>

                            </form>

                        </div>

                    </div>
                
                </div>
            
            </div>
        </section>

    </div>

</cfoutput>
