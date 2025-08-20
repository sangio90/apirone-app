<cfoutput>

    <div id="raw-value-list-root">

        <div class="row">
            <div class="col-6">
				#pageTitle()#
            </div>
			<div class="col-6 text-end pb-3">
				#addButton( bind = "click:new", size = "sm" )#
			</div>
        </div>

        <div class="row">
            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="row d-flex align-items-center mb-3">

                            <div class="col-sm-9">
								<div class="box-search-small">
									<form
										id   ="line-grid-search-form"
										class="d-flex align-items-center justify-content-end"
										data-bind: 'events: { submit: search }'>

                                        <div class="col">
                                            <span>Cerca</span>
										    <input name="str" placeholder="Cerca" class="form-control me-3" type="text">
                                        </div>

                                        <div class="col">
                                            <span>Stato</span>
                                            <select class="form-control me-3" name="statusId">
                                                <option value="">-- tutti</option>
                                                <cfloop array="#prc.page.statusList#" item="thisStatus">
                                                    <option value="#thisStatus.getId()#">#thisStatus.getName()#</option>
                                                </cfloop>
                                            </select>
                                        </div>

										<div class="align-self-end">
											#searchButton( bind = "click:search" )#
										</div>
									</form>
								</div>
							</div>                            

                            <div class="col-sm-3 text-end">

                                <div class="float-end">
                                    #deleteButton( label="Cancella", bind="click:delete", size="sm" )#
                                </div>

                            </div>

                        </div>
                        
                        <form name="raw-value-grid-form" id="raw-value-grid-form" method="post">

                            #grid( 
                                id="raw-value-grid",
                                columns="[
                                    { 'field':'shortId', 'title':'ID', width: '80px' },
                                    { 'field':'nameItem.name', 'title':'Codice', width: '150px' },
                                    { 'field':'name', 'title':'Nome'},
                                    { 'field':'', 'title':'', width: '55px'},
                                    { 
                                        'field':'', 
                                        'title':'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                        'width':'40px',
                                        'headerAttributes': { 'class': 'text-center' }
                                    }
                                ]",
                                rowTemplate="raw-value/raw-value-grid-row-tmpl"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>

    </div>

    #view("raw-value/detail-modal")#

</cfoutput>