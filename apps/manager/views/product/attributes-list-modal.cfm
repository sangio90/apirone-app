<cfoutput>

    <div id="product-attributes-list-modal" class="modal fade">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content">
                
                <header class="card-header modal-header--sticky">
                    <h2 class="card-title">Attributi</h2>
                </header>
                
                <div class="card-body">

                    <div class="row">
                    
                        <div class="col-md-12 text-end" style="margin-top: -58px; z-index: 9999999">
                            #addButton( bind="click:addAttribute", size="sm" )#
                        </div>
                        
                        <div class="col-md-12 mt-3">

                            <div class="row">
                                
                                <div class="col-12">
                                
                                    <form class="row  align-items-center mb-4" data-bind="events: { submit: search }" id="attributes-search-form">
                                        <div class="col me-2">
                                            <input class="form-control" id="attributes-search-form-str" placeholder="Cerca..." name="str" type="text" autofocus>
                                        </div>
                                        <div class="col-auto">
                                            #searchButton( bind="click:searchAttributes" )#
                                        </div>
                                    </form>
                                
                                </div>

                                <div class="col-12">
                                    #grid( 
                                        id="product-attributes-grid",
                                        columns="[
                                            { 'field':'id', 'title':'ID', width: '100px' },
                                            { 'field':'name', 'title':'Descrizione'},
                                            { 'field':'', 'title':'Aggiungi attributo al prodotto', width: '50px'},
                                            { 'field':'', 'title':'Modifica attributo', width: '50px'}
                                        ]",
                                        source="attributesList",
                                        rowTemplate="product/product-attributes-list-row-tmpl"
                                    )#
                                </div>
            
                            </div>

                        </div>
                    </div>
                
                </div>

                <footer class="card-footer modal-footer--sticky">
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