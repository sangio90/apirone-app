<cfoutput>

    <div id="properties-list-modal" class="modal fade">
        
        <section class="modal-dialog  modal-xl">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title">Cerca proprietà</h2>
                </header>
                
                <div class="card-body">        

                    <div class="row">

                        <div class="col-12 mb-2 text-end">
                            <button class="btn btn-primary btn-sm" data-bind="click:addProperty">Aggiungi proprietà +</button>
                        </div>
                    
                        <div class="col-12">

                            <div>

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
            
                                        <div>
            
                                            <table class="table table-hover pt-5">
                                                <thead>
                                                    <tr>
                                                        <th scope="col" width="50">ID</th>
                                                        <th scope="col">Proprietà</th>
                                                        <th scope="col" width="30"></th>
                                                        <th scope="col" width="30"></th>
                                                    </tr>
                                                </thead>
                                                
                                                <tbody data-bind="source:properties" data-template="property-grid-row-tmpl">
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
    
        #template( view="jstemplate/line/value-grid-row" )#
        #template( view="jstemplate/line/property-grid-row" )#

    </div>



</cfoutput>