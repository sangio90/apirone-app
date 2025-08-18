<cfoutput>
	<div id="model-list-root">

        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
            <div class="col-4 text-end">
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
										name  ="model-grid-search-form" id="model-grid-search-form"
										method="get"
										class="d-flex align-items-center justify-content-end"
										data-bind="events: { submit: search }"
									>

										<div class="col">
											<span>Cerca</span>
											<input
												class      ="form-control"
												placeholder="Cerca..." id="attributes-search-input"
												name       ="str"
											>
										</div>

										<div class="col">
											<span>Categoria</span>
											<select class="form-control" name="categoryId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.categories#" item="item">
													<option value="#item.getId()#">#item.getName()#</option>
												</cfloop>
											</select>
										</div>

										<div class="col">
											<span>Tipo</span>
											<select class="form-control" name="typeId">
												<option value="">-- tutti i tipi</option>
												<cfloop array="#prc.types#" item="item">
													<option value="#item.getId()#">#item.getName()#</option>
												</cfloop>
											</select>
										</div>

										<div class="col">
											<span>Stato</span>
											<select class="form-control" name="statusId">
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

							<div class="col-sm-2 text-end">
								<div class="float-end">
									#deleteButton(
										bind  = "click:delete",
										size  = "sm"
									)#
								</div>
							</div>

						</div>

						<form name="model-grid-form" id="model-grid-form" method="post">
							#grid(
								id      = "model-grid",
								columns = "[
                                    { 'field':'shortId', 'title':'ID', width: '80px' },
                                    { 'field':'code', 'title':'Codice', width: '80px' },
                                    { 'field':'type.id', 'title':'Tipo', width: '60px' },
                                    { 'field':'nameItem.name', 'title':'Descrizione'},
                                    { 'field':'categories', 'title':'Categorie'},
                                    { 'field':'fruitsCount', 'title':'Frutti', width: '80px'},
                                    { 'field':'', 'title':'', width: '50px'},
                                    { 
                                        'field'           :'', 
                                        'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                        'width'           :'40px',
                                        'headerAttributes': { 'class': 'text-center' }
                                    }
                                ]",
								rowTemplate = "model/model-grid-row"
							)#
						</form>
					</div>
				</section>
			</div>
		</div>

		#view( "model/detail-modal" )#
	</div>
</cfoutput>
