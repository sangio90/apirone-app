<cfoutput>

    <div id="combination-reordering-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="combination-reordering-modal-form" name="combination-reordering-modal-form" autocomplete="off">
                
                    <header class="card-header">
                        <h2 class="card-title">Riordina elementi</h2>
                    </header>
                    
                    <div class="card-body">                
                        
                        <div class="col-12 text-right mb-2" id="combination-reordering-status">
                        </div>
                        <div class="col-12">

                            #grid(
                                id      = "combination-ordering-items-grid",
                                class   = "no-pager",
                                columns = "[
                                    { 'field':'Id', 'title':'ID', width: '60px' },
                                    { 'field':'name', 'title':'Attributo' },
                                    { 'field':'', 'title':'Riordina', width: '55px'},
                                ]",
                                source: "items",
                                rowTemplate = "combination/combination-ordering-item-row-tmpl"
                            )#

                        </div>

                    
                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 text-end">
                                <button type="button" class="btn btn-default btn-sm me-2" data-bs-dismiss="modal">Chiudi</button>
                            </div>
                        </div>
                    </footer>                    
                
                </form>

            </div>
        </section>

    </div>

</cfoutput>
