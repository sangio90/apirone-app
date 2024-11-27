<cfoutput>

    <div id="product-category-list-root">

        #pageTitle()#

        <div class="row">
            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <form name="product-category-grid-form" id="product-category-grid-form" method="post">

                            #grid( 
                                source="rows",
                                id="product-category-grid",
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
                                rowTemplate="category-product/product-category-grid-row-tmpl"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>
    </div>

</cfoutput>