<cfoutput>
	<div id="production-time-list-root">
		
        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
			<!---
            <div class="col-4 text-end pt-3">
                #addButton( bind="click:new", size="sm" )#
            </div>
			---->
        </div>

		<div class="row">

			<div class="col-lg-12">
				<section class="card">
					<div class="card-body">
						<div class="row">
							<div class="col-sm-6">
								<div class="mb-3 box-search-small">
									<form
										id   ="production-time-grid-search-form"
										class="d-flex align-items-center justify-content-end"
										data-bind: 'events: { submit: search } '>
										
                                        <input name="str" placeholder="Cerca" class="form-control me-2" type="text">

										#searchButton( bind = "click:search" )#
									</form>
								</div>
							</div>
							<div class="col-sm-6 text-end mt-4">
								<div class="float-end">
									#deleteButton(
										label = "Cancella",
										bind  = "click:delete",
										size  = "sm"
									)#
								</div>

								<div class="status mt-1 float-end me-3" id="status-delete"></div>
							</div>
						</div>

						<form name="production-time-grid-form" id="production-time-grid-form" method="post">
							<div class="col-12">
								#grid(
									id      = "line-grid",
									columns = "[
                                        { 'field':'id', 'title':'ID', width: '100px' },
                                        { 'field':'name', 'title':'Descrizione' },
                                        { 'field':'', 'title':'', width: '60px' },
                                        { 
                                            'field'           :'', 
                                            'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                            'width'           :'40px',
                                            'headerAttributes': { 'class': 'text-center' }
                                        }
                                    ]",
									rowTemplate = "production-time/production-time-grid-row-tmpl"
								)#
							</div>
						</form>
					</div>
				</section>
			</div>
		</div>
	</div>

	<!--- #view( "production-time/detail-modal" )# --->

</cfoutput>
