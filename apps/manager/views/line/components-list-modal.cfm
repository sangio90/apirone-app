<cfoutput>

    <div id="components-list-modal" class="modal fade">
        
        <section class="modal-dialog  modal-xl">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title">Cerca componenti</h2>
                </header>
                
                <div class="card-body">        

                    <div class="row">
                        <div class="col-md-6 mb-5">
                            Tipologia materiale
                            <select class="form-control">
                                <option value="">Finitura</option>
                                <option value="">Profilo</option>
                                <option value="">Fissaggio</option>
                            </select>
                        </div>

                        <div class="col-md-6 mb-5">
                            Materiale
                            <select class="form-control">
                                <cfloop array="#prc.finishes#" item="item">
                                    <option value="#item.id#">#item.name#</option>
                                </cfloop>
                            </select>
                        </div>
                    </div>


                    <div class="row">
                    
                        <div class="col-8">

                            <div data-bind="visible: showSearchPanel">

                                <form class="pb-2" data-bind="events: { submit: searchComponents }" id="components-search">
                                    <div class="row">
                                        <div class="col-md-10 col-sm-12">
                                            <input class="form-control" placeholder="Cerca..." id="components-search-input">
                                        </div>
                                        <div class="col-md-2 col-sm-12">
                                            <button class="btn btn-primary" value="Cerca" data-bind="click: searchComponents">Cerca</button>
                                        </div>
                                    </div>
                                </form>
            
                                <form id="components-list-search-form" class="row">
            
                                    <div class="col-md-12">
                                        
                                        <div class="status">
                                            Fai una ricerca
                                        </div>
            
                                        <div data-bind="visible: showSearchResult">
            
                                            <table class="table table-hover pt-5">
                                                <thead>
                                                    <tr>
                                                        <th scope="col">Lavorazioni</th>
                                                        <th scope="col" width="100"></th>
                                                    </tr>
                                                </thead>
                                                
                                                <tbody data-bind="source:components" data-template="product-components-list-row-tmpl">
                                                </tbody>
                                            </table>
            
                                        </div>
            
                                    </div>
            
                                </form>

                            </div>

                            #view("product/components-list-variants")#
                                 
                        </div>
                        <div class="col-4">
                            <h3>Ho selezionato:</h3>

                            <table class="table table-hover pt-5">
                                <thead>
                                    <tr>
                                        <th scope="col">Componente</th>
                                        <th scope="col">Variante</th>
                                        <th scope="col">Colore</th>
                                        <th scope="col">Qta</th>
                                        <th scope="col" width="20"></th>
                                    </tr>
                                </thead>
                                
                                <tbody data-bind="source:selected" data-template="product-components-selected-list-row-tmpl">
                                </tbody>
                            </table>

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

    #template("jstemplate/color/product-comp-colors-row-tmpl")#
    #template("jstemplate/variant/product-comp-variants-row-tmpl")#
    #template("jstemplate/component/product-components-list-row-tmpl")#
    #template("jstemplate/component/product-components-selected-list-row-tmpl")#

</cfoutput>