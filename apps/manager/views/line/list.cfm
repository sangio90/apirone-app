<cfoutput>

    <div id="line-list-root">

        #pageTitle()#

        <div class="row">
            
            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="row">

                            <div class="col-sm-6">

                                <div class="mb-3 box-search-small"> 

                                    <form id="line-grid-search-form" 
                                        class="d-flex align-items-center justify-content-end" 
                                        data-bind:'events: { submit: search }'>

                                            <input 
                                                name="str"
                                                placeholder="Cerca"
                                                class="form-control me-2" type="text">

                                            <select 
                                                class="form-control me-2" 
                                                name="categoryId">
                                                <option value="">-- tutte le categorie</option>
                                                <cfloop array="#prc.lineCategories#" item="thisLine">
                                                    <option value="#thisLine.getId()#">#thisLine.getName()#</option>
                                                </cfloop>
                                            </select>
                                        
                                            <button type="submit" class="btn btn-primary w-auto" data-bind="click:search">Cerca ></button>
                                    
                                    </form>

                                </div>
                            
                            </div>
                            
                            <div class="col-sm-6 text-end pt-3">
                                <button type="button" class="btn btn-primary btn-sm" data-bind="click:new">Carica +</button>
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