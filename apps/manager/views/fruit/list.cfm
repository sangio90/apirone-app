<cfoutput>
	
	<div id="fruit-list-root">
		
        <div class="row">
            <div class="col-6">
				#pageTitle()#
            </div>
			<div class="col-6 text-end pb-3">
                #addButton( bind="click:new", size="sm" )#
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
										id   ="fruit-grid-search-form"
										class="d-flex align-items-center justify-content-end"
										data-bind: 'events: { submit: search }'>
										
										<div class="col">
											<span>Cerca</span>
                                        	<input name="str" placeholder="Cerca" class="form-control me-2" type="text">
										</div>

										<div class="col">
											<span>Categoria</span>
											<select class="form-control me-2" name="categoryId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.categories#" item="item">
													<option value="#item.getId()#">#item.getName()#</option>
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
												<option value="fruit.code-asc" SELECTED>Codice [A-Z]</option>
												<option value="fruit.code-desc">Codice [Z-A]</option>
												<option value="fruit.name-asc">Descrizione [A-Z]</option>
												<option value="fruit.name-desc">Descrizione [Z-A]</option>
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

						<form name="fruit-grid-form" id="fruit-grid-form" method="post">
							<div class="col-12">
								#grid(
									id      = "fruit-grid",
									columns = "[
                                        { 'field':'shortId', 'title':'ID', width: '80px' },
                                        { 'field':'code', 'title':'Codice', width: '120px' },
                                        { 'field':'name', 'title':'Descrizione' },
                                        { 'field':'name', 'title':'Categoria'},
                                        { 'field':'name', 'title':'Linee'},
                                        { 'field':'name', 'title':'Posizioni', width: '50px' },
                                        { 'field':'', 'title':'Tutti gli attributi', width: '55px'},
                                        { 'field':'', 'title':'Modifica', width: '55px'},
                                        { 
                                            'field'           :'', 
                                            'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                            'width'           :'40px',
                                            'headerAttributes': { 'class': 'text-center' }
                                        }

                                    ]",
									rowTemplate = "fruit/fruit-grid-row-tmpl"
								)#
							</div>
						</form>
					</div>
				</section>
			</div>
		</div>

		#view( "fruit/detail-modal" )#

	</div>

</cfoutput>
