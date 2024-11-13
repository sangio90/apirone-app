<cfoutput>

    <div id="line-list-root">

        <div class="row mb-3">
            <div class="col-lg-6">
                <h2>#prc.title#</h2>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="row">

                            <div class="col-sm-9">

                                <form id="line-grid-search-form" 
                                    class="row mb-3" 
                                    data-bind:'events: { submit: search }'
                                >

                                    <div class="col-4">
                                        <input 
                                            name="str"
                                            placeholder="Cerca"
                                            class="form-control" type="text">
                                    </div>

                                    <div class="col-5">
                                        <select 
                                            class="form-control" 
                                            name="categoryId">
                                            <option value="">-- tutte le categoria</option>
                                            <cfloop array="#prc.lineCategories#" item="thisLine">
                                                <option value="#thisLine.getId()#">#thisLine.getMainName()#</option>
                                            </cfloop>
                                        </select>
                                    </div>
                                    
                                    <div class="col-2">
                                        <button type="submit" class="btn btn-primary" data-bind="click:search">Cerca ></button>
                                    </div>
                                
                                </form>
                            
                            </div>

                            <div class="col-sm-3">
                                <div class="mb-3 d-flex justify-content-end col-12">
                                    <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:print">
                                        <i class="fas fa-remove"></i> Stampa
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <form name="line-grid-form" id="estimate-grid-form" method="post">
                            
                            #grid( 
                                id="line-grid",
                                columns="[
                                    { 'field':'id', 'title':'ID', width: '140px' },
                                    { 'field':'name', 'title':'Descrizione'},
                                    { 'field':'thickness.name', 'title':'Spessore'},
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

</cfoutput>