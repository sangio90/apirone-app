<cfoutput>

    <div id="values-list-modal" class="modal fade">
        
        <section class="modal-dialog  modal-xl">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title">Valori</h2>
                </header>
                
                <div class="card-body">        

                    <div class="row">
                    
                        <div class="col-12 mb-2 text-end">
                            <button class="btn btn-primary btn-sm" data-bind="click:addValue">Aggiungi valori +</button>
                        </div>

                        <div class="col-12">

                            <table class="table table-hover pt-5">
                                <thead>
                                    <tr>
                                        <th scope="col">Valore</th>
                                        <th scope="col" width="100"></th>
                                    </tr>
                                </thead>
                                
                                <tbody data-bind="source:values" data-template="value-grid-row-tmpl">
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
    
        #template( view="jstemplate/line/value-grid-row" )#

    </div>

</cfoutput>

