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
                    <section class="card-body box-search">
    
                        <form name="estimate-search-form" id="estimate-search-form" method="post">
                            <div class="row">
                                <div class="col-6">
                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Cerca</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control" placeholder="Cerca nel nome o nel codice">
                                        </div>
                                    </div>
                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Stato</label>
                                        <div class="col-sm-9">
                                            <select name="statusId" class="form-control">
                                                <option value="">-- tutti</option>
                                            </select>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6">
                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Da data</label>
                                        <div class="col-sm-9">
                                            <input type="date" name="fromDate" class="form-control" placeholder="eg.: 20/05/2020">
                                        </div>
                                    </div>
                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">A data</label>
                                        <div class="col-sm-9">
                                            <input type="date" name="toDate" class="form-control" placeholder="eg.: 20/05/2020">
                                        </div>
                                    </div>
                                    <div class="form-group row">
                                        <div class="col-sm-9 offset-sm-3">
                                            <button type="button" class="btn btn-primary btn-sm me-2" data-bind="click:search">
                                            <i class="fas fa-search"></i> Cerca
                                            </button>
                                            <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:print">
                                            <i class="fas fa-print"></i> Stampa
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>                    
    
                    </section>
                </section>                

                <section class="card">
                    
                    <div class="card-body">

                        <form name="text-grid-form" id="text-grid-form" method="post">

                            <div class="row">
                                <div class="mb-3 d-flex justify-content-end col-12">
                                    <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:print">
                                        <i class="fas fa-remove"></i> Stampa
                                    </button>
                                </div>
                            </div>
                            
                            #grid( 
                                id="line-grid",
                                columns="[
                                    { 'field':'id', 'title':'ID', width: '50px' },
                                    { 'field':'name', 'title':'Traduzione'},
                                    { 'field':'', 'title':'', width: '65px'},
                                    { 
                                        'field':'', 
                                        'title':'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                        'width':'40px',
                                        'headerAttributes': { 'class': 'text-center' }
                                    }
                                ]",
                                rowTemplate="text/text-grid-row"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>
    </div>

</cfoutput>