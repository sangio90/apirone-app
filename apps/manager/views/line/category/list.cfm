<cfoutput>

    <div id="line-category-list-root">

        #pageTitle()#

        <div class="row">
            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <form name="line-category-grid-form" id="line-category-grid-form" method="post">

                            #grid( 
                                source="rows",
                                id="line-category-grid",
                                columns="[
                                    { 'field':'id', 'title':'ID', width: '50px' },
                                    { 'field':'id', 'title':'Codice', width: '150px' },
                                    { 'field':'name', 'title':'Descrizione'},
                                    { 
                                        'field':'', 
                                        'title':'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                        'width':'40px',
                                        'headerAttributes': { 'class': 'text-center' }
                                    }
                                ]",
                                rowTemplate="line/category/line-category-grid-row-tmpl"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>
    </div>

</cfoutput>