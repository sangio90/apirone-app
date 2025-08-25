<cfoutput>

    <div id="metadata-modal-root" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <header class="card-header d-flex align-elements-center justify-content-between">
                    <h2 class="card-title" data-bind="text:getTitle"></h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                </header>

				<div class="card-body">
					<form id="metadata-detail-form" method="POST" name="metadata-detail-form">
					
						<div data-bind="source: rows" data-template="metadata-detail-row-tmpl">
						</div>

						<div class="mb-3 row" data-bind="visible: detailForm.data.id">
							<div class="col-sm-10 offset-sm-2 mt-1 fs-10 le-14">
								ID: <span data-bind="text: detailForm.data.id"></span><br>
								Creato: <span data-bind="text: detailForm.data.createdAt"></span>
							</div>
						</div>

					</form>                
				</div>

                <footer class="card-footer">
                    <div class="row">
                        <div class="col-md-4 white-small">
                            #relevantPath( getCurrentTemplatePath() )#
                        </div>
                        <div class="col-md-8 d-flex justify-content-end">
                            <div class="status errors-counter mt-1 me-3"></div>
                            <button type="button" class="btn btn-default btn-sm me-2" data-bs-dismiss="modal">Chiudi</button>
                            #saveButton(bind="click:save", size="sm")#
                        </div>
                    </div>
                </footer>                

            </div>
        </selection>

    </div>

    #template( view="jstemplate/metadata/metadata-detail-row-tmpl" )#

</cfoutput>