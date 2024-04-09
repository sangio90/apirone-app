<cfoutput>
    <div id="account-root">

        <div class="row">

            <div class="col-12">
                <h1>#prc.title#</h1>
            </div>

            <div class="col-12">

                <div class="row">
                    <div class="mb-3 d-flex justify-content-start col-6">
                        <button type="button" class="btn btn-default btn-sm" data-bind="click:new">
                            <i class="fas fa-plus"></i> Nuovo account
                        </button>
                    </div>
                </div>

                #renderView("account/form-detail")#

                <section class="card">
                    
                    <div class="card-body">

                        <form name="account-grid-form" id="account-grid-form" method="post">

                            <div class="row">
                                <div class="mb-3 d-flex justify-content-end col-12">
                                    <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:deleteAll">
                                        <i class="fas fa-remove"></i> Cancella selezionati
                                    </button>
                                    <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:print">
                                        <i class="fas fa-print"></i> Stampa
                                    </button>
                                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:saveAll">
                                        <i class="fas fa-save"></i> Salva tutto
                                    </button>
                                </div>
                            </div>
                            
                            <div 
                                id="account-grid" 
                                data-bound="ZB.kendo.toggleScrollbar"
                                data-columns="[
                                    { 'field':'email', 'title':'Email'},
                                    { 'field':'role.id', 'title':'Ruolo' },
                                    { 'field':'status.id', 'title':'Status' },
                                    { 'field':'createdAt', 'title':'Creato il' },
                                    { 'field':'', 'title':'', width: '60px'},
                                    { 'field':'', 'title':'', width: '40px'}
                                ]" 
                                data-role="grid" 
                                data-sortable="true" 
                                data-editable="inline" 
                                data-bind="source: rows" 
                                data-row-template="account-grid-row-tmpl">
                            </div>

                        </form>
                    
                    </div>
                </section>
            </div>
        </div>

    </div>

    #template( view="jstemplates/account-grid-row" )#

</cfoutput>