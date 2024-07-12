<cfoutput>

    <div id="components-list-modal" class="modal fade">
        
        <section class="modal-dialog  modal-lg">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title">Cerca componenti</h2>
                </header>
                
                <div class="card-body">        

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
                                            <th scope="col">ID</th>
                                            <th scope="col">Nome</th>
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

    #template("jstemplate/component/product-components-list-row-tmpl")#

</cfoutput>