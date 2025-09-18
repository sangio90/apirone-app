<cfoutput>

    <div id="audit-entry-list-root">

        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
        </div>

        <div class="row">

            <div class="col-lg-12">

                <section class="card">
                    <section class="card-body box-search">
    
                        <form name="audit-entry-search-form" id="audit-entry-search-form" method="post" data-bind="events: { submit: search }">
                            <div class="row">
                                <div class="col-6">
                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Cerca</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control" placeholder="Cerca traduzione">
                                        </div>
                                    </div>
                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Sezione</label>
                                        <div class="col-sm-9">
                                            <select name="entityId" class="form-control">
                                                <option value="">-- tutte</option>
                                                <cfloop collection="#prc.entities#" item="item">
                                                    <option value="#item#">#item#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Azione</label>
                                        <div class="col-sm-9">
                                            <select name="actionId" class="form-control">
                                                <option value="">-- tutte</option>
                                                <cfloop collection="#prc.actions#" item="item">
                                                    <option value="#item#">#item#</option>
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
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>                    
    
                    </section>
                </section>

                <section class="card">
                    
                    <div class="card-body">
                        
                        <form name="audit-entry-grid-form" id="audit-entry-grid-form" method="post">

                            #grid( 
                                id="audit-entry-grid",
                                columns="[
                                    { 'field':'shortId', 'title':'ID', width: '50px'},
                                    { 'field':'createdAt', 'title':'Creato il', width: '140px' },
                                    { 'field':'entity', 'title':'Sezione', width: '130px'},
                                    { 'field':'action', 'title':'Azione', width: '130px'},
                                    { 'field':'message', 'title':'Messagge'},
                                    { 'field':'ipAddress', 'title':'IP', width: '120px' },
                                    { 'field':'account.name', 'title':'Account', width: '200px' },
                                    { 'field':'', 'title':'', width: '55px'}
                                ]",
                                rowTemplate="audit-entry/audit-entry-grid-row-tmpl"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>

        #view("audit-entry/detail-modal")#

    </div>

</cfoutput>
