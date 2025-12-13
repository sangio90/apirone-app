<cfoutput>
    <div id="combination-config-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="combination-config-form" method="POST" name="combination-config-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title">Attributi per cui le combinazioni</h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

                        <div class="mb-3 row">
                            <label class="col-sm-3 col-form-label text-end">Seleziona attributi</label>
                            <div class="col-sm-9">
                                <select id="combination-config-attributes" 
                                    data-placeholder="-- Seleziona gli attributi"
                                    data-role="multiselect" 
                                    data-bind="source: attributesForSuggest, value: attributeList" 
                                    data-value-field="id"
                                    data-text-field="name">
                                </select>
                                
                                <script type="text/template" id="product-attribute-suggest-list-row-xx">
                                    <div>
                                        <span data-bind="text: name"></span>
                                    </div>
                                </script>
                            </div>
                        </div>

                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:generate">
                                    <i class="fas fa-save"></i> Genera
                                </button>
                                <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                                <div class="status errors-counter mt-1 float-end me-3"></div>
                            </div>
                        </div>
                    </footer>

                </form>

            </div>
        </section>
    
    </div>

</cfoutput>