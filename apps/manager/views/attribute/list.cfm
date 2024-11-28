<cfoutput>

    <div id="attribute-list-root">

        #pageTitle()#

        <div class="row">
            <div class="col-lg-12 text-end mb-3">
                #addButton( bind="click:new", size="sm" )#
            </div>
        </div>
    
        <div class="row">
            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="row d-flex align-items-center mb-3">

                            <div class=" box-search-small col-8">

                                <form id="attribute-grid-search-form" 
                                    class="d-flex align-items-center justify-content-end" 
                                    data-bind:'events: { submit: search }'
                                >

                                    <input name="str" placeholder="Cerca" class="form-control me-3" type="text">

                                    <select class="form-control me-3" name="categoryId">
                                        <option value="">-- tutte le categorie</option>
                                        <cfloop array="#prc.lineCategories#" item="thisLine">
                                            <option value="#thisLine.getId()#">#thisLine.getName()#</option>
                                        </cfloop>
                                    </select>
                                    
                                    <select class="form-control me-3" name="statusId">
                                        <option value="">-- status</option>
                                        <cfloop array="#prc.statuses#" item="thisStatus">
                                            <option value="#thisStatus.getId()#">#thisStatus.getName()#</option>
                                        </cfloop>
                                    </select>

                                    #searchButton(bind="click:search")#
                                    
                                </form>
                            
                            </div>

                            <div class="col-sm-4 text-end">

                                <div class="float-end">
                                    #deleteButton( label="Cancella", bind="click:delete", size="sm" )#
                                </div>

                            </div>

                        </div>
                        
                        <form name="attribute-grid-form" id="attribute-grid-form" method="post">

                            #grid( 
                                id="attribute-grid",
                                columns="[
                                    { 'field':'shortId', 'title':'ID', width: '80px' },
                                    { 'field':'name', 'title':'Descrizione'},
                                    { 'field':'category.name', 'title':'Categorie'},
                                    { 'field':'', 'title':'Numero di valori', width: '55px'},
                                    { 'field':'', 'title':'', width: '55px'},
                                    { 
                                        'field':'', 
                                        'title':'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                        'width':'40px',
                                        'headerAttributes': { 'class': 'text-center' }
                                    }
                                ]",
                                rowTemplate="attribute/attribute-grid-row-tmpl"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>

    </div>

    #view("attribute/detail-modal")#

</cfoutput>