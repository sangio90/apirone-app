<cfoutput>

    <div id="size-list-root">

        <div class="row mb-3">
            <div class="col-lg-6">
                <h2>#prc.title#</h2>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <form name="size-grid-form" id="size-grid-form" method="post">

                            <div class="row">
                                <div class="mb-3 d-flex justify-content-end col-12">
                                    <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:print">
                                        <i class="fas fa-remove"></i> Stampa
                                    </button>
                                </div>
                            </div>
                            
                            #grid( 
                                id="size-grid",
                                columns="[
                                    { 'field':'shortId', 'title':'ID', width: '80px' },
                                    { 'field':'code', 'title':'Codice', width: '80px' },
                                    { 'field':'categories', 'title':'Categorie'},
                                    { 'field':'fruitsCount', 'title':'Frutti'},
                                    { 'field':'', 'title':'', width: '50px'},
                                    { 
                                        'field':'', 
                                        'title':'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                        'width':'40px',
                                        'headerAttributes': { 'class': 'text-center' }
                                    }
                                ]",
                                rowTemplate="size/size-grid-row"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>

        #view("finish/detail-modal")#
        
    </div>

</cfoutput>