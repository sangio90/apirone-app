<cfoutput>

    <div id="attribute-detail-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="attribute-detail-form" method="POST" name="attribute-detail-form">
                
                    <header class="card-header">
                        <h2 class="card-title" data-bind="text:title"></h2>
                    </header>
                    
                    <div class="card-body">

                        <div class="mb-3 row">
                            <label for="attrId" class="col-sm-2 col-form-label text-end">ID</label>
                            <div class="col-sm-10">
                                <input type="text" required class="form-control col-sm-4" id="attrId" name="attrId"
                                    maxlength="10"
                                    data-bind="value: detailForm.id"
                                    onkeyup="this.value = this.value.toUpperCase();">
                            </div>
                        </div>

                        <div data-bind="source: detailForm.texts" data-template="attribute-lang-row-tmpl">
                        </div>
                    
                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 float-end">
                                <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:save">
                                    <i class="fas fa-save"></i> Salva
                                </button>
                                <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                                <div class="status errors-counter mt-1 float-end me-3"></div>
                            </div>
                        </div>
                    </footer>

                </form>
            
            </div>
        </selection>
    
    </div>

    #template( view="jstemplate/attribute/lang-row" )#

</cfoutput>