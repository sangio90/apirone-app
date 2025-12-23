<cfoutput>

    <div id="account-list-root">

        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
            <div class="col-4 text-end">
                #addButton( bind="click:new", size="sm" )#
            </div>
        </div>

        <div class="row">

            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="row d-flex align-items-center mb-3 ">

                            <div class="col-sm-8">

                                <div class="box-search-small"> 

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

                            <div class="col-sm-4 text-end">

                                <div class="float-end">
                                    #deleteButton( label="Cancella", bind="click:delete", size="sm" )#
                                </div>

                            </div>
                            
                        </div>
                        
                        <form name="account-grid-form" id="account-grid-form" method="post">

                            #grid( 
                                id="account-grid",
                                columns="[
                                    { 'field':'shortId', 'title':'ID', width: '80px'},
                                    { 'field':'email', 'title':'Email'},
                                    { 'field':'name', 'title':'Nome'},
                                    { 'field':'createdAt', 'title':'Creato il', width: '140px' },
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
