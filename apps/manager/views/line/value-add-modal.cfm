<cfoutput>

    <div id="value-add-modal" class="modal fade">
        
        <section class="modal-dialog  modal-xl">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title">Aggiungi valori</h2>
                </header>
                
                <div class="card-body">        

                    <div class="row">
                    
                        <div class="col-12">

                            <table class="table table-hover pt-5">
                                <thead>
                                    <tr>
                                        <th scope="col" width="100">ID</th>
                                        <th scope="col">Valore</th>
                                    </tr>
                                </thead>
                                
                                <tbody>
                                    <tr>
                                        <td><input class="form-control"></td>
                                        <td><input class="form-control"></td>
                                    </tr>
                                    <tr>
                                        <td><input class="form-control"></td>
                                        <td><input class="form-control"></td>
                                    </tr>
                                    <tr>
                                        <td><input class="form-control"></td>
                                        <td><input class="form-control"></td>
                                    </tr>
                                </tbody>
                            </table>

                            <p>
                                <button class="btn btn-primary btn-sm" data-bind="click:addValue">Aggiungi tutti</button>
                            </p>

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

    </div>

</cfoutput>

