<cfoutput>

    <div id="account-detail-modal" class="modal fade">

        <section class="modal-dialog modal-lg">
            <div class="modal-content">
                    
                <header class="card-header d-flex align-elements-center justify-content-between">
                    <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                </header>                
                
                <div class="card-body">

                    <ul class="nav nav-tabs" role="tablist">
                        <li class="nav-item active">
                            <a class="nav-link active" id="tab1-tab" data-bs-toggle="tab" href="##tab1" role="tab" aria-controls="tab1" aria-selected="true"
                                data-bind="click:showDetail"
                            >Generale</a>
                        </li>
                        <li class="nav-item" data-bind="visible:isTabPasswordVisible">
                            <a class="nav-link" id="tab2-tab" data-bs-toggle="tab" href="##tab2" role="tab" aria-controls="tab2" aria-selected="true"
                                data-bind="click:showPassword"
                            >Cambia password</a>
                        </li>
                    </ul>

                    <div class="tab-content">

                        <div class="tab-pane p-2 fade show active" id="tab1" role="tabpanel" aria-labelledby="tab1-tab">

                            <form id="account-detail-form">

                                <div class="row">

                                    <div class="col-6">
                                        <div class="form-group pb-3">
                                            <label class="col-form-label" for="account-desc">Nome</label>
                                            <input class="form-control" name="name" id="name" 
                                                required
                                                data-rule-required="true"
                                                data-msg-required="Nome richiesto"
                                                data-bind="value: detailForm.data.name"
                                                >
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
                                            <input class="form-control" name="email" id="email" data-bind="value: detailForm.data.email" required>
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
                                            <select type="text" class="form-control" name="status" 
                                                required
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
                                            <input class="form-control" id="pwd" name="pwd" type="password" required>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="form-group">
                                            <label class="col-form-label">Conferma password</label>
                                            <input class="form-control" name="pwd2" type="password" required
                                                data-bind="value: detailForm.data.pwd"
                                            >
                                        </div>
                                    </div>
                                </div>

                            </form>

                        </div>
                        
                        <div class="tab-pane p-2 fade" id="tab2" role="tabpanel" aria-labelledby="tab2-tab">

                            <form id="account-password-form">

                                <div class="row">
                                    <div class="col-6">
                                        <div class="form-group">
                                            <label class="col-form-label" for="account-desc">Password</label>
                                            <input class="form-control" id="newPwd" name="newPwd" type="password" required>
                                            <div class="row">
                                                <div class="col-sm-8" id="newPwd-error">
                                                </div>

                                                <div class="col-sm-4 text-end">
                                                    <a href="javascript:;" data-bind="click:togglePassword" class="underline float-end fs-12" tabindex="-1" id="label-change-type">Mostra password</a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="form-group">
                                            <label class="col-form-label" for="account-desc">Conferma password</label>
                                            <input class="form-control" id="newPwd2" name="newPwd2" type="password" required>
                                        </div>
                                    </div>
                                </div>

                            </form>

                        </div>
                    </div>
                
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