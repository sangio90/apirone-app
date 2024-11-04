<cfoutput>

    <div id="report-list-root">

        <div class="row mb-3">
            <div class="col-lg-6">
                <h2>#prc.title#</h2>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <form name="report-grid-form" id="report-grid-form" method="post">

                            <div class="row">
                                <div class="mb-3 d-flex justify-content-end col-12">
                                    <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:print">
                                        <i class="fas fa-remove"></i> Stampa
                                    </button>
                                </div>
                            </div>
                            
                            #grid( 
                                id="report-grid",
                                columns="[
                                    { 'field':'id', 'title':'ID', width: '50px' },
                                    { 'field':'name', 'title':'Descrizione'},
                                    { 'field':'', 'title':'File JRXML', width: '450px'},
                                    { 'field':'', 'title':'File di esempio', width: '450px'},
                                    { 'field':'', 'title':'', width: '65px'},
                                    { 
                                        'field':'', 
                                        'title':'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                        'width':'40px',
                                        'headerAttributes': { 'class': 'text-center' }
                                    }
                                ]",
                                rowTemplate="report/report-grid-row"
                            )#

                        </form>
                                        
                    </div>
                </section>
            
            </div>
        </div>
    
    </div>

</cfoutput>