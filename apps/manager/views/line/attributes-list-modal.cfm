<cfoutput>

    <div id="line-attributes-list-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title">Attributi</h2>
                </header>
                
                <div class="card-body">

                    <div class="row">
                    
                        <div class="col-md-12 text-end">
                            <button class="btn btn-primary btn-sm" data-bind="click:addAttribute">Carica </button>
                        </div>
                        
                        <div class="col-md-12 mt-3">

                            <div>

                                <form class="pb-2" data-bind="events: { submit: search }" id="attributes-search">
                                    <div class="row">
                                        <div class="col-md-10 col-sm-12">
                                            <input class="form-control" placeholder="Cerca..." id="attributes-search-input">
                                        </div>
                                        <div class="col-md-2 col-sm-12">
                                            <button class="btn btn-primary" value="Cerca" data-bind="click: searchAttributes">Cerca</button>
                                        </div>
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
                                            { 'field':'', 'title':'Configurazione', width: '65px'},
                                            { 
                                                'field':'', 
                                                'title':'<input type=checkbox onclick=AP.util.checkAll(this) name=selectAll>', 
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