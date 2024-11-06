<cfoutput>

    <div id="text-detail-modal" class="modal fade">
        
        <section class="modal-dialog modal-xl">
            <div class="modal-content">
                
                <header class="card-header">
                    <h2 class="card-title" data-bind="text: detailForm.title"></h2>
                </header>
                
                <div class="card-body">

                    <div class="row">
                    
                        <div class="col-md-12 mt-3">

                            <form id="text-list-form" class="row">

                                <div data-bind="source: detailForm.data.texts" data-template="text-detail-row-tmpl">
                                </div>
        
                            </form>

                        </div>
                    </div>
                
                </div>

                <footer class="card-footer">
                    <div class="row">
                        <div class="col-md-12 float-end">
                            <button type="button" class="btn btn-primary btn-sm float-end" data-bind="click:save">
                                <i class="fas fa-save"></i> <span data-bind="text: detailForm.labelButton"></span>
                            </button>
                            <button type="button" class="btn btn-default btn-sm me-2 float-end" data-bs-dismiss="modal">Chiudi</button>
                            <div class="status errors-counter mt-1 float-end me-3" id="attribute-values-add-form-status"></div>
                        </div>
                    </div>
                </footer>
    
            </div>
        </selection>
    
    </div>

    #template( view="jstemplate/text/text-detail-row-tmpl" )#

</cfoutput>