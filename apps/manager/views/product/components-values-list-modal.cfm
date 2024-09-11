<cfoutput>

    <div id="components-values-list-modal" class="modal fade">
        
        <section class="modal-dialog  modal-xl">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title">Lista attributi</h2>
                </header>
                
                <div class="card-body">        

                    <div class="row">
                    
                        <div class="col-12">

                            <div>

                                <div class="col-md-12">
                                    
                                    <form id="components-values-list-search-form" class="row">
                                        <div>
                                            <table class="table table-hover pt-5">
                                                <thead>
                                                    <tr>
                                                        <th scope="col" width="100">ID</th>
                                                        <th scope="col">Valore</th>
                                                    </tr>
                                                </thead>

                                                <tbody data-bind="source:values" data-template="value-list-row-tmpl">
                                                </tbody>
                                                
                                            </table>
        
                                        </div>
                                    </form>
        
                                </div>

                                <div class="col-md-12">
                                    <h3>Aggiungi valore</h3>
                                    
                                    <form id="components-values-add-value-form" class="row">

                                        <div class="row">
                                            <div class="col-md-10 col-sm-12">
                                                <input class="form-control" placeholder="Aggiungi valore...">
                                            </div>
                                            <div class="col-md-2 col-sm-12">
                                                <button class="btn btn-primary">Aggiungi</button>
                                            </div>
                                        </div>
                                        
                                    </form>
                                
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

    #template("jstemplate/attribute/value-list-row")#

</cfoutput>