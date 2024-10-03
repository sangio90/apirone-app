<cfoutput>

    <div id="attributes-list-modal" class="modal fade">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title">Cerca attributi</h2>
                </header>
                
                <div class="card-body">        

                    <div class="row">
                    
                        <div class="col-md-12">

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

                            <div data-bind="visible: showSearchPanel">
            
                                <form id="attributes-list-search-form" class="row">
            
                                    <div class="col-md-12">
                                        
                                        <div class="status">
                                            Fai una ricerca
                                        </div>
            
                                        <div data-bind="visible: showSearchResult">
            
                                            <table class="table table-hover pt-5">
                                                <thead>
                                                    <tr>
                                                        <th scope="col" width="100">ID</th>
                                                        <th scope="col">Nome</th>
                                                        <th scope="col" width="100"></th>
                                                    </tr>
                                                </thead>
                                                
                                                <tbody data-bind="source:attributesList" data-template="line-attributes-list-row-tmpl">
                                                </tbody>
                                            </table>
            
                                        </div>
            
                                    </div>
            
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

    <!----
    #template("jstemplate/color/product-comp-colors-row-tmpl")#
    #template("jstemplate/variant/product-comp-variants-row-tmpl")#
    #template("jstemplate/component/product-components-list-row-tmpl")#
    #template("jstemplate/component/product-components-selected-list-row-tmpl")#
    ---->
    #template("jstemplate/line/line-attributes-list-row-tmpl")#

</cfoutput>