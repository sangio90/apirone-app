<cfoutput>

    <div id="line-attributes-list-modal" class="modal fade">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title">Attributi</h2>
                </header>
                
                <div class="card-body">

                    <div class="row">
                    
                        <div class="col-md-12 text-end" style="margin-top: -58px; z-index: 9999999">
                            <button class="btn btn-primary btn-sm" data-bind="click:addAttribute">Carica </button>
                        </div>
                        
                        <div class="col-md-12 mt-3">

                            <div>
                                
                                <form class="d-flex align-items-center mb-4" data-bind="events: { submit: search }" id="attributes-search">
                                    <div class="col me-2">
                                        <input class="form-control" placeholder="Cerca..." id="attributes-search-input">
                                    </div>
                                    <div class="col-auto">
                                        <button class="btn btn-primary" value="Cerca" data-bind="click: searchAttributes">Cerca &raquo;</button>
                                    </div>
                                </form>

                            </div>

                            <div>
                                
                                <form id="line-attributes-list-search-form" class="row">

                                    #grid( 
                                        id="line-attributes-grid",
                                        columns="[
                                            { 'field':'id', 'title':'ID', width: '100px' },
                                            { 'field':'name', 'title':'Descrizione'},
                                            { 'field':'', 'title':'', width: '50px'},
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