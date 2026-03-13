
<cfoutput>

    <div id="text-list-root">

        <div class="row mb-3">
            <div class="col-lg-6">
                <h2>#prc.title#</h2>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">

                <section class="card">
                    <section class="card-body box-search">
    
                        <form name="text-search-form" id="text-search-form" method="post" data-bind="events: { submit: search }">
                            <div class="row">
                                <div class="col-6">
                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Cerca</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control" placeholder="Cerca traduzione">
                                        </div>
                                    </div>
                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Lingua</label>
                                        <div class="col-sm-9">
                                            <select name="langId" class="form-control">
                                                <cfloop array="#prc.langs#" item="item">
                                                    <option value="#item.getId()#" <cfif item.getId() IS "IT">SELECTED</cfif>>#item.getName()#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Stato</label>
                                        <div class="col-sm-9">
                                            <select name="statusId" class="form-control">
                                                <option value="">-- tutti</option>
                                                <cfloop array="#prc.statusList#" item="item">
                                                    <option value="#item.getId()#">#item.getName()#</option>
                                                </cfloop>
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
                                            <!--- <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:createAllTraduzioniMancanti">
                                            <i class="fas fa-flag"></i> Creazione Massiva Traduzioni Mancanti
                                            </button> --->
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
                                id="text-list-grid",
                                columns="[
                                    { 'field':'id', 'title':'ID', width: '70px' },
                                    { 'field':'name', 'title':'Traduzione'},
                                    { 'field':'name', 'title':'Lingua'},
                                    { 'field':'name', 'title':'Tipo'},
                                    { 'field':'entity', 'title':'Riferimento'},
                                    { 'field':'', 'title':'Stati', width: '300px' },
                                    { 'field':'', 'title':'', width: '55px'},
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

        #view("text/detail-modal")#

    </div>

</cfoutput>