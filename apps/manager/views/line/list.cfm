<cfoutput>

    <div id="line-list-root">

        #pageTitle()#

        <div class="row">

            <div class="col-sm-12 text-end pb-3">
                #addButton( "Carica linea", "click:new", "sm" )#
            </div>
            
            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="row">

                            <div class="col-sm-6">

                                <div class="mb-3 box-search-small"> 

                                    <form id="line-grid-search-form" 
                                        class="d-flex align-items-center justify-content-end" 
                                        data-bind:'events: { submit: search }'>

                                        <input name="str" placeholder="Cerca" class="form-control me-2" type="text">

                                        <select class="form-control me-2" name="categoryId">
                                            <option value="">-- tutte le categorie</option>
                                            <cfloop array="#prc.lineCategories#" item="thisLine">
                                                <option value="#thisLine.getId()#">#thisLine.getName()#</option>
                                            </cfloop>
                                        </select>
                                    
                                        #searchButton( "Cerca linea", "click:search" )#
                                    
                                    </form>

                                </div>
                            
                            </div>
                            
                        </div>
                        
                        <form name="line-grid-form" id="estimate-grid-form" method="post">

                            #grid( 
                                id="line-grid",
                                columns="[
                                    { 'field':'shortId', 'title':'ID', width: '80px' },
                                    { 'field':'code', 'title':'Codice', width: '120px' },
                                    { 'field':'name', 'title':'Descrizione' },
                                    { 'field':'category.name', 'title':'Categoria'},
                                    { 'field':'thickness.name', 'title':'Spessore', width: '110px'},
                                    { 'field':'', 'title':'Modifica', width: '55px'},
                                    { 'field':'', 'title':'Possibili combinazioni', width: '55px'},
                                    { 'field':'', 'title':'Dimensioni e finiture', width: '55px'},
                                    { 
                                        'field':'', 
                                        'title':'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                        'width':'40px',
                                        'headerAttributes': { 'class': 'text-center' }
                                    }
                                ]",
                                rowTemplate="line/line-grid-row-tmpl"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>

    </div>

    #view("line/detail-modal")#

</cfoutput>