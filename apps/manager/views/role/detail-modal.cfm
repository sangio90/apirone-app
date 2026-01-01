<cfoutput>
    <div id="role-permissions-modal" class="modal fade">
        
        <section class="modal-dialog modal-lg">
            <div class="modal-content">

                <form id="role-permissions-form" method="POST" name="role-permissions-form">
                
                    <header class="card-header d-flex align-elements-center justify-content-between">
                        <h2 class="card-title" data-bind="text:detailForm.title"></h2>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
                    </header>                
                        
                    <div class="card-body">

                        <div class="mb-3 row">
                            <div class="col-12">
                                <div class="form-group pb-3">
                                    <label class="col-sm-2 col-form-label text-start">Entità</label>
                                    <select type="text" class="form-control" name="entity" 
                                        required
                                        data-bind="source: detailForm.entities, value: detailForm.data.entity, events: { change: getPermissions }"
                                        data-value-field="id"
                                        data-text-field="name"
                                    >
                                    </select>
                                </div>
                            </div>
                        </div>
                        
                        <div class="mb-3 row">
                             #grid( 
                                id="permission-grid",
                                class="no-pager hidden",
                                columns="[
                                    { 'field':'id', 'title':'ID', width: '30%' },
                                    { 'field':'name', 'title':'Nome', width: '30%'},
                                    { 'field':'createdAt', 'title':'Data', width: '30%'},
                                    { 
                                        'field':'', 
                                        'title':'<input type=checkbox name=selectAll>',
                                        'width':'35px',
                                        'headerAttributes': { 'class': 'justify-content-center' }
                                    }
                                ]",
                                source="detailForm.data.entity.permissions",
                                rowTemplate="role/permissions-tmpl"
                             )#
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
        </section>
    
        #template( view="jstemplate/role/permissions-tmpl" )#
    </div>
    

</cfoutput>
