<cfoutput>

    <div id="components-colors-list-modal" class="modal fade">
        
        <section class="modal-dialog  modal-lg">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title">Colori per <span data-bind="text: titleComponent"></span></h2>
                </header>
                
                <div class="card-body">        

                    <form id="components-colors-list-search-form" class="row">

                        <div class="col-md-12">
                            
                            <div>

                                <table class="table table-hover pt-5">
                                    <thead>
                                        <tr>
                                            <th scope="col">ID</th>
                                            <th scope="col">Nome</th>
                                            <th scope="col" width="100"></th>
                                        </tr>
                                    </thead>
                                    
                                    <tbody data-bind="source:colors" data-template="color-list-row-tmpl">
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

    #template("jstemplate/color/list-row-tmpl")#

</cfoutput>