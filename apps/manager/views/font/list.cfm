<cfoutput>

    <div id="font-list-root">

        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
            <div class="col-4 text-end">
                #addButton( bind="click:new", size="md" )#
            </div>
        </div>

        <div class="row">

            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="row d-flex align-items-center mb-3">

                            <div class="col-sm-10">

                                <div class="mb-3 box-search-small"> 

                                    <form id="font-grid-search-form" 
                                        class="d-flex justify-content-end" 
                                        data-bind:'events: { submit: search }'>

                                        <input name="str" placeholder="Cerca" class="form-control me-2" type="text">

                                        <select class="form-control me-2" name="orderBy">
                                            <option value="font.code-asc">Codice [A-Z]</option>
                                            <option value="font.code-desc">Codice [Z-A]</option>
                                        </select>

                                        <div style="align-self: flex-end;">
                                            #searchButton( bind="click:search" )#
                                        </div>
                                    
                                    </form>

                                </div>

                            </div>

							<div class="col-sm-2">
								<div class="float-end">
									#deleteButton(
										bind  = "click:delete",
										size  = "sm"
									)#
								</div>

								<div class="status float-end me-3" id="status-delete"></div>
							</div>

                        </div>
                        
                        <form name="font-grid-form" id="font-grid-form" method="get">

                            #grid( 
                                id="font-grid",
                                columns="[
                                    { 'field':'shortId', 'title':'ID', width: '5%' },
                                    { 'field':'code', 'title':'Codice', width: '50%' },
                                    { 'field':'dimension', 'title':'Ingombro (mm)', width: '30%' },
                                    { 'field':'', 'title':'Modifica', width: '10%' },
                                    { 'field':'', 'title':'', width: '5%' }
                                ]",
                                rowTemplate="font/font-grid-row-tmpl"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>

    </div>

	#view( "font/detail-modal" )#

</cfoutput>