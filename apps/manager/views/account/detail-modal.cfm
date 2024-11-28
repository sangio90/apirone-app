<cfoutput>

    <div id="account-detail-modal" class="modal fade">

        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="account-detail-form">
                    
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                    
                    <div class="card-body">
                        <div class="row">

                            <div class="col-6">
                                <div class="form-group pb-3">
                                    <label class="col-form-label" for="account-desc">Nome</label>
                                    <input class="form-control" name="name" id="name" data-bind="value: detailForm.data.name">
                                </div>
                            </div>

                            <div class="col-6">
                                <div class="form-group pb-3">
                                    <label class="col-form-label" for="account-desc">Lingua</label>
                                    <select required
                                        class="form-control"
                                        data-bind="source: detailForm.langs, value: detailForm.data.lang.id" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>                                        
                                </div>
                            </div>

                        </div>

                        <div class="row">
                            <div class="col-6">
                                <div class="form-group pb-3">
                                    <label class="col-form-label">Email</label>
                                    <input class="form-control" name="email" id="email" data-bind="value: detailForm.data.email">
                                </div>
                            </div>

                            <div class="col-6">
                                <div class="form-group pb-3">
                                    <label class="col-form-label">Telefono</label>
                                    <input class="form-control" name="phone" id="phone" data-bind="value: detailForm.data.phone">
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-6">
                                <div class="form-group pb-3">
                                    <label class="col-form-label">Ruoli</label>
                                    <select id="roles" required
                                        data-role="multiselect"
                                        data-bind="source: detailForm.roles, value: detailForm.data.selectedRoles" 
                                        data-value-field="id"
                                        data-text-field="name"
                                        >
                                    </select>
                                </div>
                            </div>
                            
                            <div class="col-6">
                                <div class="form-group pb-3">
                                    <label class="col-form-label" for="account-desc">Stato</label>
                                    <select type="text" class="form-control" name="status" required
                                        data-bind="value: detailForm.data.status.id, source: detailForm.statuses"
                                        data-value-field="id"
                                        data-text-field="name"
                                    >
                                    </select>
                                </div>
                            </div>

                        </div>

                        <div class="row" data-bind="invisible: isUpdate">
                            <div class="col-6">
                                <div class="form-group">
                                    <label class="col-form-label">Password</label>
                                    <input class="form-control ignore" id="pwd" name="pwd" type="password" required
                                        data-bind="value: detailForm.data.pwd"
                                        data-rule-required="true"
                                        data-msg-required="Password richiesta"
                                        data-rule-pwdRule="true"
                                        data-msg-pwdRule="Almeno 8 caratteri, un numero, un carattere speciale"
                                    >
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="form-group">
                                    <label class="col-form-label">Conferma password</label>
                                    <input class="form-control ignore" name="pwd2" type="password" required
                                        data-rule-required="true"
                                        data-msg-required="Conferma la password"
                                        data-rule-equalTo="##pwd"
                                        data-msg-equalTo="Le password non coincidono"
                                    >
                                </div>
                            </div>
                        </div>

                    </div>

                    <footer class="card-footer">
                        <div class="row">
                            <div class="col-md-12 d-flex justify-content-end">
                                <div class="status errors-counter mt-1 me-3"></div>
                                <button type="button" class="btn btn-default btn-sm me-2" data-bs-dismiss="modal">Chiudi</button>
                                #saveButton( bind="click:save", size="sm")#
                            </div>
                        </div>
                    </footer>

                </form>
            
            </div>
        </section>  

    </div>

</cfoutput>