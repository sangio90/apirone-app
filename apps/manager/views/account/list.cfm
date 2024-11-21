<cfoutput>

    <div id="account-list-root">

        #pageTitle()#

        <div class="row">

            <div class="col-sm-12 text-end pb-3">
                <button type="button" class="btn btn-primary btn-sm" data-bind="click:new">Carica +</button>
            </div>
            
            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="row">

                            <div class="col-sm-6">

                                <div class="mb-3 box-search-small"> 

                                    <form id="account-grid-search-form" 
                                        class="d-flex align-items-center justify-content-end" 
                                        data-bind:'events: { submit: search }'>

                                        <input name="str" placeholder="Cerca" class="form-control me-2" type="text">

                                        <select class="form-control me-2" name="categoryId">
                                            <option value="">-- tutti i ruoli</option>
                                            <cfloop array="#[]#" item="thisLine">
                                                <option value="#thisLine.getId()#">#thisLine.getName()#</option>
                                            </cfloop>
                                        </select>
                                    
                                        <button type="submit" class="btn btn-primary w-auto" data-bind="click:search">Cerca ></button>
                                    
                                    </form>

                                </div>
                            
                            </div>
                            
                        </div>
                        
                        <form name="account-grid-form" id="account-grid-form" method="post">

                            #grid( 
                                id="account-grid",
                                columns="[
                                    { 'field':'email', 'title':'Email'},
                                    { 'field':'role.id', 'title':'Ruolo' },
                                    { 'field':'status.id', 'title':'Status' },
                                    { 'field':'createdAt', 'title':'Creato il' },
                                    { 'field':'', 'title':'', width: '60px'},
                                    { 'field':'', 'title':'', width: '40px'},
                                    { 
                                        'field':'', 
                                        'title':'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                        'width':'40px',
                                        'headerAttributes': { 'class': 'text-center' }
                                    }                                     
                                ]",
                                rowTemplate="account/account-grid-row-tmpl"
                            )#


                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>

    </div>

    <!--- #view("line/detail-modal")# ---->

</cfoutput>


<!-------------

    <cfoutput>
    <div id="role-list-root">

        <div class="row">

            <cf_pageTitle prc="#prc#">

            <div class="col-12">

                <div class="row">
                    <div class="mb-3 d-flex justify-content-start col-6">
                        <button type="button" class="btn btn-default btn-sm" data-bind="click:new">
                            <i class="fas fa-plus"></i> Nuovo ruolo
                        </button>
                    </div>
                </div>

                <section class="card">
                    
                    <div class="card-body">

                        <form name="account-grid-form" id="account-grid-form" method="get">

                            <div class="row">
                                <div class="mb-3 d-flex justify-content-end col-12">
                                    <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:deleteAll">
                                        <i class="fas fa-remove"></i> Cancella selezionati
                                    </button>
                                    <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:print">
                                        <i class="fas fa-print"></i> Stampa
                                    </button>
                                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:saveAll">
                                        <i class="fas fa-save"></i> Salva tutto
                                    </button>
                                </div>
                            </div>

                            <table class="table table-ecommerce-simple table-striped mb-0" id="datatable-ecommerce-list" style="min-width: 750px;">

                                <thead>
                                    <tr>
                                        <th width="5%">ID</th>
                                        <th>Nome</th>
                                        <th>Email</th>
                                        <th>Phone</th>
                                        <th>Role</th>
                                        <th width="3%"><input type="checkbox" name="select-all" class="select-all checkbox-style-1 p-relative top-2" value="" /></th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <cfloop array="#prc.list#" item="item">
                                        <tr>
                                            <td><a href="/manager/accounts/#item.id#">#item.id#</td>
                                            <td><a href="/manager/accounts/#item.id#"><strong>#item.name# #item.surname#</strong></a></td>
                                            <td>#item.email#</td>
                                            <td>#item.phone#</td>
                                            <td nowrap>#item.role#</td>
                                            <td width="30"><input type="checkbox" name="checkboxRow1" class="checkbox-style-1 p-relative top-2" value="" /></td>
                                        </tr>
                                    </cfloop>
                                </tbody>
                            </table>

                            
                            <!---
                            <div 
                                id="account-grid" 
                                data-bound="AP.kendo.toggleScrollbar"
                                data-columns="[
                                    { 'field':'email', 'title':'Email'},
                                    { 'field':'role.id', 'title':'Ruolo' },
                                    { 'field':'status.id', 'title':'Status' },
                                    { 'field':'createdAt', 'title':'Creato il' },
                                    { 'field':'', 'title':'', width: '60px'},
                                    { 'field':'', 'title':'', width: '40px'}
                                ]" 
                                data-role="grid" 
                                data-sortable="true" 
                                data-editable="inline" 
                                data-bind="source: rows" 
                                data-row-template="account-grid-row-tmpl">
                            </div>
                            ---->

                        </form>
                    
                    </div>
                </section>
            </div>
        </div>

    </div>

    #template( view="jstemplate/account/account-grid-row" )#

</cfoutput>

----->