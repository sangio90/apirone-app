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
