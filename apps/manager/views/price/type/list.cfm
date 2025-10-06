<cfoutput>

    <div id="price-type-list-root">

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

                        <div class="row d-flex align-items-center mb-3">

                            <div class="col-sm-10">

                                <div class="mb-3 box-search-small"> 

                                    <form id="price-type-grid-search-form" 
                                        class="d-flex justify-content-end" 
                                        data-bind:'events: { submit: search }'>

                                        <div class="col">
                                            <span>Cerca</span>
                                            <input name="str" placeholder="Cerca" class="form-control me-2" type="text">
                                        </div>

                                        <div class="col">
                                            <span>Metodo</span>
                                            <select class="form-control me-2" name="methodId">
                                                <option value="">-- tutte</option>
                                                <cfloop array="#prc.methods#" item="thisMethod">
                                                    <option value="#thisMethod.getId()#">#thisMethod.getName()#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                    
                                        <div class="col">
                                            <span>Entità</span>
                                            <select class="form-control me-2" name="entityId">
                                                <option value="">-- tutte</option>
                                                <cfloop array="#prc.entities#" item="thisEntity">
                                                    <option value="#thisEntity.getId()#">#thisEntity.getName()#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                    
                                        <div class="col">
                                            <span>Status</span>
                                            <select class="form-control me-2" name="statusId">
                                                <option value="">-- tutti</option>
                                                <cfloop array="#prc.statuses#" item="thisStatus">
                                                    <option value="#thisStatus.getId()#">#thisStatus.getName()#</option>
                                                </cfloop>
                                            </select>
                                        </div>

                                        <div class="align-self-end">
                                            #searchButton( bind="click:search" )#
                                        </div>
                                    
                                    </form>

                                </div>

                            </div>
                            <div class="col-sm-2">
                                <div class="float-end">
                                    #deleteButton(
                                        bind  = "click:delete",
                                        size  = "sm"
                                    )#
                                </div>

                                <div class="status float-end me-3" id="status-delete"></div>
                            </div>

                        </div>
                        
                        <form name="price-type-grid-form" id="price-type-grid-form" method="post">

                            #grid( 
                                id="price-type-grid",
                                columns="[
                                    { 'field':'shortId', 'title':'ID', width: '180px' },
                                    { 'field':'name', 'title':'Nome'},
                                    { 'field':'methods', 'title':'Metodi'},
                                    { 'field':'entities', 'title':'Usa in'},
                                    { 'field':'', '':'', width: '50px' },
                                    { 
                                        'field':'', 
                                        'title':'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                        'width':'40px',
                                        'headerAttributes': { 'class': 'text-center' }
                                    }
                                ]",
                                rowTemplate="price/type/price-type-grid-row-tmpl"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>

        #view("price/type/detail-modal")#

    </div>

</cfoutput>