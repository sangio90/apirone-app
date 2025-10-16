<cfoutput>

    <div id="font-family-list-root">

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

                                    <form id="font-family-grid-search-form" 
                                        class="d-flex justify-content-end" 
                                        data-bind:'events: { submit: search }'>

                                        <input name="str" placeholder="Cerca" class="form-control me-2" type="text">

                                        <select class="form-control me-2" name="orderBy">
                                            <option value="fontFamily.code-asc">Codice [A-Z]</option>
                                            <option value="fontFamily.code-desc">Codice [Z-A]</option>
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
                        
                        <form name="font-family-grid-form" id="font-family-grid-form" method="get">

                            #grid( 
                                id="font-family-grid",
                                columns="[
                                    { 'field':'id', 'title':'ID', width: '10%', 'headerAttributes': { 'class': 'justify-content-center' } } ,
                                    { 'field':'code', 'title':'Codice', width: '30%' },
                                    { 'field':'name', 'title':'Nome', width: '40%'},
                                    { 'field':'', 'title':'', width: '15%'},
                                    { 
                                        'field'           :'', 
                                        'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                        'width'           :'5%',
                                        'headerAttributes': { 'class': 'justify-content-center' }
                                    }
                                ]",
                                rowTemplate="font-family/font-family-grid-row-tmpl"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>

    </div>

	#view( "font-family/detail-modal" )#

</cfoutput>