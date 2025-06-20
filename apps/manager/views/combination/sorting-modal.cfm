<cfoutput>

    <div id="combination-sorting-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <header class="card-header d-flex align-elements-center justify-content-between">
                    <h2 class="card-title">Riordina elementi</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                </header>

                <nav>

                    <ul class="nav nav-tabs" role="tablist">
                        <li class="nav-item active">
                            <a class="nav-link active" id="combination-sorting-nav-values-but" data-bs-toggle="tab" 
                                href="##combination-sorting-nav-values-tab" role="tab" aria-controls="tab1" aria-selected="true">
                                Valori
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" id="combination-sorting-nav-attributes-but" data-bs-toggle="tab" 
                                href="##combination-sorting-nav-attributes-tab" role="tab" aria-controls="tab2" aria-selected="true">
                                Attributi
                            </a>
                        </li>
                        <div class="tab-status">
                        </div>
                    </ul>

                </nav>

                <div class="card-body">

                    <div class="tab-content" id="nav-tabContent">

                        <div class="tab-pane fade show active" id="combination-sorting-nav-values-tab" role="tabpanel" aria-labelledby="combination-sorting-nav-values-tab">              
                    
                            <form id="combination-sorting-modal-form" name="combination-sorting-modal-form" autocomplete="off">
                            
                                <div class="col-12 text-end mb-2" id="combination-sorting-status">
                                </div>
                                
                                <div class="col-12">

                                    #grid(
                                        id      = "combination-ordering-items-grid",
                                        class   = "no-pager",
                                        columns = "[
                                            { 'field':'Id', 'title':'ID', width: '60px' },
                                            { 'field':'name', 'title':'Attributo/Valore' },
                                            { 'field':'', 'title':'Riordina', width: '55px'},
                                        ]",
                                        source: "orderingItems",
                                        rowTemplate = "combination/combination-ordering-item-row-tmpl"
                                    )#

                                </div>

                            </form>

                        </div>
                        
                        <div class="tab-pane fade show" id="combination-sorting-nav-attributes-tab" role="tabpanel" aria-labelledby="combination-sorting-nav-values-tab">              

                            <form id="combination-sorting-attribute-modal-form" name="combination-sorting-attribute-modal-form" autocomplete="off">
                            
                                <div class="col-12 text-end mb-2" id="combination-sorting-attribute-status">
                                </div>
                                
                                <div class="col-12">

                                    #grid(
                                        id      = "combination-ordering-attributes-grid",
                                        class   = "no-pager",
                                        columns = "[
                                            { 'field':'Id', 'title':'ID', width: '60px' },
                                            { 'field':'name', 'title':'Attributo' },
                                            { 'field':'', 'title':'Riordina', width: '55px'},
                                        ]",
                                        source: "orderingAttributes",
                                        rowTemplate = "combination/combination-ordering-attribute-row-tmpl"
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
