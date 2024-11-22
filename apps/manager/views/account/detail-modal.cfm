<cfoutput>
    <div id="account-detail-modal" class="modal fade">

        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="account-detail-form">
                    <section class="card card-featured card-featured-primary mb-4">

                        <header class="card-header">
                            <h2 class="card-title" data-bind="text: detailForm.title"></h2>
                        </header>
                        
                        <div class="card-actions">
                            <a href="##" class="card-action card-action-dismiss" data-dismiss="account-item"></a>
                        </div>

                        <div class="card-body">
                            <div class="row pb-3">

                                <div class="col-lg-12">
                                    <div class="row">
                                        <div class="col-12">
                                            <div class="form-group pb-3">
                                                <label class="col-form-label" for="account-desc">Nome</label>
                                                <input class="form-control" name="email" id="email" data-bind="value: detailForm.data.name">
                                            </div>
                                        </div>
                                    </div>

                                </div>

                                <div class="col-lg-12">
                                    <div class="row">
                                        <div class="col-6">
                                            <div class="form-group pb-3">
                                                <label class="col-form-label" for="account-desc">Email</label>
                                                <input class="form-control" name="email" id="email" data-bind="value: detailForm.data.email">
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="form-group pb-3">
                                                <label class="col-form-label" for="account-desc">Telefono</label>
                                                <input class="form-control" name="email" id="email" data-bind="value: detailForm.data.phone">
                                                </select>
                                            </div>
                                        </div>

                                    </div>
                                </div>

                                <div class="col-lg-12">
                                    <div class="row">
                                        <div class="col-6">
                                            <div class="form-group pb-3">
                                                <label class="col-form-label" for="account-desc">Ruolo</label>
                                                <select type="text" class="form-control" name="role"
                                                    data-bind="value: detailForm.data.role.id, source: roles, events: { change: setRole }"
                                                    data-value-field="id"
                                                    data-text-field="name"
                                                >
                                                </select>
                                            </div>
                                            <div class="row" id="list-role-admin">
                                                <div class="col-12">
                                                    Permessi per admin:
                                                </div>

                                                <div class="col-12">
                                                    <cfloop array="#prc.perms#" item="item">
                                                        <div class="checkbox">
                                                            <label>
                                                                <input type="checkbox" value="#item.id#" <cfif ArrayContains(item.roles, "ADM")>checked</cfif>  > #item.name#
                                                            </label>
                                                        </div>
                                                    </cfloop>
                                                </div>
                                                
                                            </div>

                                            <div class="row" id="list-role-commercial" style="display:none;">
                                                <div class="col-12">
                                                    Permessi per commerciale:
                                                </div>

                                                <div class="col-12">
                                                    <cfloop array="#prc.perms#" item="item">
                                                        <div class="checkbox">
                                                            <label>
                                                                <input type="checkbox" value="#item.id#" <cfif ArrayContains(item.roles, "COM")>checked</cfif>  > #item.name#
                                                            </label>
                                                        </div>
                                                    </cfloop>
                                                </div>
                                                
                                            </div>


                                        </div>
                                        <div class="col-6">
                                            <div class="form-group pb-3">
                                                <label class="col-form-label" for="account-desc">Stato</label>
                                                <select type="text" class="form-control" name="status"
                                                    data-bind="value: detailForm.data.status.id, source: statusList"
                                                    data-value-field="id"
                                                    data-text-field="name"
                                                >
                                                </select>
                                            </div>
                                        </div>

                                    </div>

                                </div>
                                
                                <div class="col-lg-12">
                                    <div class="row">
                                        <div class="col-6">
                                            <div class="form-group">
                                                <label class="col-form-label" for="account-desc">Password</label>
                                                <input class="form-control" id="pwd" name="pwd">
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="form-group">
                                                <label class="col-form-label" for="account-desc">Conferma password</label>
                                                <input class="form-control" name="pwd2">
                                            </div>
                                        </div>

                                    </div>

                                </div>

                                <div class="col-lg-12">
                                    <div class="row">
                                        <div class="col-6">
                                            <div class="form-group mt-4">
                                                <div class="checkbox">
                                                    <label>
                                                        <input type="checkbox" value="">
                                                        Attiva doppia autenticazione
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                        </div>

                                    </div>

                                </div>
                            </div>
                        </div>
                        <footer class="card-footer text-end">
                            <button type="button" class="btn btn-primary btn-sm" data-bind="click:save">
                                <i class="fas fa-save"></i> Salva
                            </button>

                        </footer>
                    </section>
                </form>
            
            </div>
        </section>  

    </div>

</cfoutput>