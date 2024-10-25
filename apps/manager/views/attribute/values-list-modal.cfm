<cfoutput>

    <div id="attribute-values-list-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title" data-bind="text:title"></h2>
                </header>
                
                <div class="card-body">

                    <div class="row">
                        <nav>
                            <div class="nav nav-tabs" id="nav-tab" role="tablist">
                                <button class="nav-link active" id="attribute-nav-detail-but" data-bs-toggle="tab" type="button" role="tab"
                                    data-bs-target="##attribute-nav-detail-tab" aria-controls="attribute-nav-detail-tab" aria-selected="true">
                                        Dettaglio
                                </button>
                                <button class="nav-link" id="attribute-nav-values-but" data-bs-toggle="tab"  type="button" role="tab"
                                    data-bs-target="##attribute-nav-values-tab" aria-controls="attribute-nav-values-tab" aria-selected="false">
                                        Valori
                                </button>
                            </div>
                        </nav>
                        <div class="tab-content" id="nav-tabContent">
                            <div class="tab-pane fade show active" id="attribute-nav-detail-tab" role="tabpanel" aria-labelledby="attribute-nav-detail-but">
                                <!--- tab 1 ---->

                                <p>Detail</p>

                            </div>

                            <div class="tab-pane fade" id="attribute-nav-values-tab" role="tabpanel" aria-labelledby="attribute-nav-values-but">
                                <!--- tab 2 ---->

                                <div class="col-md-6 mt-3">

                                    <div>
                                        <form id="line-attributes-list-search-form" class="row">
        
                                            #grid( 
                                                id="attribute-values-grid",
                                                columns="[
                                                    { 'field':'id', 'title':'ID', width: '100px' },
                                                    { 'field':'name', 'title':'Descrizione'},
                                                    { 'field':'status', 'title':'Status', width: '30px', headerAttributes: { 'class': 'kendo-tooltip tw-100'}},
                                                    { 'field':'', 'title':'', width: '65px'},
                                                    { 
                                                        'field':'', 
                                                        'title':'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                                        'width':'40px',
                                                        'headerAttributes': { 'class': 'text-center' }
                                                    }
                                                ]",
                                                source="attributesList",
                                                rowTemplate="line/line-attributes-list-row-tmpl"
                                            )#
                    
                                        </form>
        
                                    </div>
        
                                </div>
        
                                <div class="col-md-6 mt-3">
                                    Dettaglio riga
                                </div>

                            </div>
                        </div>
                    
                    </div>
                
                </div>

                <footer class="card-footer">
                    <div class="row">
                        <div class="col-md-12 text-end">
                            <button type="button" class="btn btn-default btn-sm me-2" data-bs-dismiss="modal">Chiudi</button>
                        </div>
                    </div>
                </footer>
            
            </div>
        </selection>
    
    </div>

</cfoutput>