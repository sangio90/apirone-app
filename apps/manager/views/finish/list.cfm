<cfoutput>

    <div id="finish-list-root">

        #pageTitle()#

        <div class="row">

            <div class="col-lg-12 text-end mb-3">
                <button type="submit" class="btn btn-primary btn-sm" data-bind="click:new">Carica +</button>
            </div>

            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="row">

                            <div class="col-sm-9">

                                <div class="mb-3 box-search-small"> 

                                    <form id="finish-grid-search-form" 
                                        class="d-flex align-items-center justify-content-end" 
                                        data-bind:'events: { submit: search }'>

                                        <input name="str" placeholder="Cerca" class="form-control me-2" type="text">

                                        <select class="form-control me-2" name="categoryId">
                                            <option value="">-- tutte le categorie</option>
                                            <cfloop array="#prc.lineCategories#" item="thisLine">
                                                <option value="#thisLine.getId()#">#thisLine.getName()#</option>
                                            </cfloop>
                                        </select>
                                    
                                        <select class="form-control me-2" name="statusId">
                                            <option value="">-- status</option>
                                            <cfloop array="#prc.statuses#" item="thisStatus">
                                                <option value="#thisStatus.getId()#">#thisStatus.getName()#</option>
                                            </cfloop>
                                        </select>
                                    
                                        <button type="submit" class="btn btn-primary" data-bind="click:search">Cerca ></button>
                                    </form>
                            
                                </div>
                            
                            </div>

                        </div>
                        
                        <form name="finish-grid-form" id="finish-grid-form" method="post">

                            #grid( 
                                id="finish-grid",
                                columns="[
                                    { 'field':'shortId', 'title':'ID', width: '80px' },
                                    { 'field':'code', 'title':'Codice', width: '80px'},
                                    { 'field':'name', 'title':'Descrizione'},
                                    { 'field':'category.name', 'title':'Categorie'},
                                    { 'field':'', 'title':'', width: '55px'},
                                    { 
                                        'field':'', 
                                        'title':'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                        'width':'40px',
                                        'headerAttributes': { 'class': 'text-center' }
                                    }
                                ]",
                                rowTemplate="finish/finish-grid-row-tmpl"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>

        #view("finish/detail-modal")#

    </div>

</cfoutput>