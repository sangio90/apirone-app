<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
	<div id="global-metadata-list-root">

        <div class="row">
            <div class="col-6">
				#pageTitle()#
            </div>
        </div>

		<div class="row">
			<div class="col-lg-12">
				<section class="card">
					<div class="card-body">
						
						<div class="row d-flex align-items-center mb-3">
							<div class="col-sm-10">
								<div class="box-search-small">
									<form
										id="global-metadata-list-search-form"
										class="d-flex align-items-center justify-content-end"
										data-bind: 'events: { submit: search }'>
										
										<div class="col">
											<span>Cerca</span>
											<input name="str" placeholder="Cerca" class="form-control me-2" type="text">
										</div>

										<div class="col">
											<span>Status</span>
											<select class="form-control me-2" name="statusId">
												<option value="">-- tutti</option>
												<cfloop array="#prc.statuses#" item="item">
													<option value="#item.getId()#">#item.getName()#</option>
												</cfloop>
											</select>
										</div>


										<div class="align-self-end">
											#searchButton( bind = "click:search" )#
										</div>
									</form>
								</div>
							</div>

							<div class="col-sm-2">
								<div class="float-end">
									#saveButton(
										bind  = "click:save",
										size  = "sm"
									)#
								</div>

								<div class="status float-end me-3" id="status-delete"></div>
							</div>
						</div>

						<form name="global-metadata-grid-form" id="global-metadata-grid-form" method="post">
							<div class="col-12">
								#grid(
									id      = "global-metadata-grid",
									columns = "[
                                        { 'field':'id', 'title':'ID', width: '60px' },
	                                    { 'field':'name', 'title':'Nome' },
                                        { 'field':'createdAt', 'title':'Creato il', width: '160px' },
                                        { 'field':'unit', 'title':'Unità', 'width': '300px' },
                                        { 'field':'', 'title':'Valore', width: '200px'},
                                    ]",
									rowTemplate = "global-metadata/global-metadata-grid-row-tmpl"
								)#
							</div>
						</form>
					</div>
				</section>
			</div>
		</div>
	</div>

</cfoutput>
