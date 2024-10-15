<cfoutput>

    <div id="attribute-detail-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title" data-bind="text:title"></h2>
                </header>
                
                <div class="card-body">

                    <div class="row">
                    
                        <div class="col-md-12 mt-3">

                            <form id="line-attributes-list-search-form" class="row">

                                <div class="mb-3 row">
                                    <label for="attrId" class="col-sm-2 col-form-label">ID</label>
                                    <div class="col-sm-10">
                                        <input type="text" required class="form-control" id="attrId" value="">
                                    </div>
                                </div>

                                <div data-bind="source: texts">

                                    <div class="mb-3 row">
                                        <label for="lang_##=uid##" class="col-sm-2 col-form-label" data-bind="text:name"></label>
                                        <div class="col-sm-10">
                                            <input type="text" required class="form-control" id="lang_##=uid##" value="" data-bind="value:name">
                                        </div>
                                    </div>
                                
                                </div>

                            </form>

                        </div>
                    </div>
                
                </div>

                <footer class="card-footer">
                    <div class="row">
                        <div class="col-md-12 text-end">
                            <button type="button" class="btn btn-primary btn-sm me-2" data-bs-dismiss="modal">Salva</button>
                            <button type="button" class="btn btn-default btn-sm me-2" data-bs-dismiss="modal">Chiudi</button>
                        </div>
                    </div>
                </footer>
            
            </div>
        </selection>
    
    </div>

</cfoutput>