<cfoutput>

    <div id="combination-attributes-list-modal" class="modal fade">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title">Attributi</h2>
                </header>
                
                <div class="card-body">

                    <div class="row">
                    
                        <div class="col-md-12 text-end" style="margin-top: -58px; z-index: 9999999">
                            #addButton( bind="click:addAttribute", size="sm" )#
                        </div>
                        
                        <div class="col-md-12 mt-3">

                            <div>
                                
                                <form class="row  align-items-center mb-4" data-bind="events: { submit: search }" id="attributes-search-form">
                                    <div class="col me-2">
                                        <input class="form-control" placeholder="Cerca..." name="str">
                                    </div>
                                    <div class="col-auto">
                                        <button class="btn btn-primary" value="Cerca" data-bind="click: searchAttributes">Cerca &raquo;</button>
                                    </div>
                                </form>

                            </div>

                            <div>
                                
                                <form id="combination-attributes-list-search-form" class="row">

                                    #grid( 
                                        id="combination-attributes-grid",
                                        columns="[
                                            { 'field':'id', 'title':'ID', width: '100px' },
                                            { 'field':'name', 'title':'Descrizione'},
                                            { 'field':'', 'title':'Aggiungi attributo alla combinazione', width: '50px'},
                                            { 'field':'', 'title':'Modifica attributo', width: '50px'}
                                        ]",
                                        source="attributesList",
                                        rowTemplate="combination/combination-attributes-list-row-tmpl"
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