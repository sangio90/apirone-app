<cfoutput>

    <div id="user-detail-modal" class="modal fade">

        <section class="modal-dialog modal-lg">
            <div class="modal-content">
                    
                <header class="card-header d-flex align-elements-center justify-content-between">
                    <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                </header>                
                
                <div class="card-body">

                    <form id="user-detail-form">

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Nome</label>
                            <div class="col-sm-10">
                                <input class="form-control" name="name" id="name" 
                                    required
                                    data-rule-required="true"
                                    data-msg-required="Nome richiesto"
                                    data-bind="value: detailForm.data.name"
                                    >
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Lingua</label>
                            <div class="col-sm-10">
                                <select required name="langId" id="langId"
                                    class="form-control"
                                    data-bind="source: detailForm.langs, value: detailForm.data.lang.id" 
                                    data-value-field="id"
                                    data-text-field="name"
                                    >
                                </select>  
                            </div>
                        </div>

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Telefono</label>
                            <div class="col-sm-10">
                                <input class="form-control" name="phone" id="phone" 
                                    data-bind="value: detailForm.data.phone">
                            </div>
                        </div>                            

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Ruolo</label>
                            <div class="col-sm-10">
                                <select id="roles" name="roleId" id="roleId"
                                    class="form-control"
                                    data-bind="source: detailForm.roles, value: detailForm.data.role" 
                                    data-value-field="id"
                                    data-text-field="name"
                                    >
                                </select>                                
                            </div>
                        </div>                            

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Stato</label>
                            <div class="col-sm-10">
                                <select class="form-control" name="status" 
                                    required
                                    data-bind="value: detailForm.data.status, source: detailForm.statuses"
                                    data-value-field="id"
                                    data-text-field="name"
                                    >
                                </select>
                            </div>
                        </div>                            

                        <div class="mb-3 row">
                            <label class="col-sm-2 col-form-label text-end">Account</label>
                            <div class="col-sm-10">
                                <select id="accountId" name="accountId" class="form-control"
                                    required
                                    data-bind="source: detailForm.accounts, value: detailForm.data.account" 
                                    data-value-field="id"
                                    data-text-field="email"
                                    >
                                </select>
                            </div>
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
                        <div class="col-md-12 d-flex justify-content-end">
                            <div class="errors-counter mt-1 me-3"></div>
                            <div class="status"></div>
                            <button type="button" class="btn btn-default btn-sm me-2" data-bs-dismiss="modal">Chiudi</button>
                            #saveButton( bind="click:save, text:detailForm.buttonLabel", size="sm" )#
                        </div>
                    </div>
                </footer>
            
            </div>
        </section>  

    </div>

</cfoutput>