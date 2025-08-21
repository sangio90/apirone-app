<cfoutput>
	<div id="metadata-type-list-root">

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
							<div class="col-sm-10">
								<div class="box-search-small">
									<form
										id   ="metadata-type-grid-search-form"
										class="d-flex align-items-center justify-content-end"
										data-bind: 'events: { submit: search }'>
										
										<div class="col">
											<span>Cerca</span>
											<input name="str" placeholder="Cerca" class="form-control me-2" type="text">
										</div>

										<div class="col">
											<span>Unità</span>
											<select class="form-control me-2" name="categoryId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.units#" item="thisUnit">
													<option value="#thisUnit.getId()#">#thisUnit.getName()#</option>
												</cfloop>
											</select>
										</div>

										<div class="col">
											<span>Datatype</span>
											<select class="form-control me-2" name="datatypeId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.datatypes#" item="thisType">
													<option value="#thisType.getId()#">#thisType.getName()#</option>
												</cfloop>
											</select>
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

										<div class="col">
											<span>Ordina per</span>
											<select class="form-control me-2" name="orderBy">
												<option value="metadataType.code-asc" SELECTED>Codice [A-Z]</option>
												<option value="metadataType.code-desc">Codice [Z-A]</option>
												<option value="metadataType.name-asc">Nome [A-Z]</option>
												<option value="metadataType.name-desc">Nome [Z-A]</option>
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
									#deleteButton(
										bind  = "click:delete",
										size  = "sm"
									)#
								</div>

								<div class="status float-end me-3" id="status-delete"></div>
							</div>
						</div>

						<form name="metadata-type-grid-form" id="metadata-type-grid-form" method="post">
							<div class="col-12">
								#grid(
									id      = "metadata-type-grid",
									columns = "[
                                        { 'field':'id', 'title':'ID', width: '50px' },
                                        { 'field':'code', 'title':'Codice', width: '100px' },
                                        { 'field':'name', 'title':'Nome' },
                                        { 'field':'entities', 'title':'Entità' },
                                        { 'field':'unit', 'title':'Unità' },
                                        { 'field':'', 'title':'Modifica', width: '55px'},
                                        { 
                                            'field'           :'', 
                                            'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>',
                                            'width'           :'40px',
                                            'headerAttributes': { 'class': 'text-center' }
                                        }
                                    ]",
									rowTemplate = "metadata-type/metadata-type-grid-row-tmpl"
								)#
							</div>
						</form>
					</div>
				</section>
			</div>
		</div>
	</div>

	#view( "metadata-type/detail-modal" )#

</cfoutput>
