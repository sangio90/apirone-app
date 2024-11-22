<cfoutput>

    <div id="account-list-root">

        #pageTitle()#

        <div class="row">

            <div class="col-sm-12 text-end pb-3">
                #addButton(bind="click:new", size="sm")#
            </div>
            
            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="row">

                            <div class="col-sm-8">

                                <div class="mb-3 box-search-small"> 

                                    <form id="account-grid-search-form" 
                                        class="d-flex align-items-center justify-content-end" 
                                        data-bind:'events: { submit: search }'>

                                        <input name="str" placeholder="Cerca" class="form-control me-2" type="text">

                                        <select class="form-control me-2" name="roleId">
                                            <option value="">-- tutti i ruoli</option>
                                            <cfloop array="#prc.roles#" item="thisLine">
                                                <option value="#thisLine.getId()#">#thisLine.getName()#</option>
                                            </cfloop>
                                        </select>
                                    
                                        <select class="form-control me-2" name="statusId">
                                            <option value="">-- tutti gli stati</option>
                                            <cfloop array="#prc.statuses#" item="thisLine">
                                                <option value="#thisLine.getId()#">#thisLine.getName()#</option>
                                            </cfloop>
                                        </select>
                                    
                                        #searchButton(bind="click:search")#
                                    
                                    </form>

                                </div>
                            
                            </div>

                            <div class="col-sm-4 text-end mt-4">

                                <div class="float-end">
                                    #deleteButton( label="Cancella", bind="click:delete", size="sm" )#
                                </div>

                                <div class="status mt-1 float-end me-3" id="status-delete"></div>

                            </div>

                            
                        </div>
                        
                        <form name="account-grid-form" id="account-grid-form" method="post">

                            #grid( 
                                id="account-grid",
                                columns="[
                                    { 'field':'shortId', 'title':'ID', width: '80px'},
                                    { 'field':'email', 'title':'Email'},
                                    { 'field':'role.id', 'title':'Ruolo' },
                                    { 'field':'lang.id', 'title':'Lingua' },
                                    { 'field':'createdAt', 'title':'Creato il' },
                                    { 'field':'', 'title':'', width: '50px'},
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

    #view("account/detail-modal")#

</cfoutput>
