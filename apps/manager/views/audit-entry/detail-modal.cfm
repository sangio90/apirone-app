<cfoutput>

    <div id="audit-entry-detail-modal" class="modal fade">

        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="audit-entry-detail-form">
                    
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                    
                    <div class="card-body">
                        <div class="row">

                            <div class="col-6">
                                <div class="form-group pb-3">
                                    <label class="col-form-label" for="audit-entry-desc">Sezione</label>
                                    <div class="form-control-static" data-bind="text: detailForm.data.entity"></div>
                                </div>
                            </div>

                            <div class="col-6">
                                <div class="form-group pb-3">
                                    <label class="col-form-label" for="audit-entry-desc">Azione</label>
                                    <div class="form-control-static" data-bind="text: detailForm.data.action"></div>
                                </div>
                            </div>

                            <div class="col-6">
                                <div class="form-group pb-3">
                                    <label class="col-form-label" for="audit-entry-desc">Account</label>
                                    <div class="form-control-static" data-bind="text: detailForm.data.account.name"></div>
                                </div>
                            </div>
                            
                            <div class="col-6">
                                <div class="form-group pb-3">   
                                    <label class="col-form-label" for="audit-entry-desc">Importanza</label>
                                    <div class="form-control-static" data-bind="text: detailForm.data.severity"></div>
                                </div>
                            </div>

                            <div class="col-6">
                                <div class="form-group pb-3">
                                    <label class="col-form-label" for="audit-entry-desc">Data</label>
                                    <div class="form-control-static" data-bind="text: detailForm.data.createdAt"></div>
                                </div>
                            </div>

                            <div class="col-6">
                                <div class="form-group pb-3">
                                    <label class="col-form-label" for="audit-entry-desc">IP</label>
                                    <div class="form-control-static" data-bind="text: detailForm.data.ipAddress"></div>
                                </div>
                            </div>

                            <div class="col-12">
                                <div class="form-group pb-3">
                                    <label class="col-form-label" for="audit-entry-desc">User agent</label>
                                    <div class="form-control-static" data-bind="text: detailForm.data.userAgent"></div>
                                </div>
                            </div>

                        </div>


                        <div class="row">
                            <div class="col-12">
                                <div class="form-group pb-3">
                                    <label class="col-form-label" for="audit-entry-desc">Message</label>
                                    <div class="form-control-static" data-bind="text: detailForm.data.message"></div>
                                </div>
                            </div>
                            
                            <div class="col-12">
                                <div class="form-group pb-3">   
                                    <label class="col-form-label" for="audit-entry-desc">Payload</label>
                                    <textarea class="form-control-static" style="height: 170px;" data-bind="value: detailForm.data.payload"></textarea>
                                </div>
                            </div>

                        </div>

                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 d-flex justify-content-end">
                                <button type="button" class="btn btn-default btn-sm me-2" data-bs-dismiss="modal">Chiudi</button>
                            </div>
                        </div>
                    </footer>

                </form>
            
            </div>
        </section>  

    </div>

</cfoutput>