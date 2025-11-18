<cfoutput>
	
	<div id="product-list-root">

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
							<div class="col-sm-12">
								<div class="box-search-small">
									<form
										id   ="product-grid-search-form"
										class="d-flex align-items-center justify-content-end"
										data-bind: 'events: { submit: search }'>

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
											<span>Linea</span>
											<select class="form-control me-2" name="lineId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.lines#" item="item">
													<option value="#item.getId()#">#item.getName()#</option>
												</cfloop>
											</select>
										</div>

										<div class="col">
											<span>Modello</span>
											<select class="form-control me-2" name="modelId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.models#" item="item">
													<option value="#item.getId()#">#item.getName()# (#item.getCode()#)</option>
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
												<option value="product.code-asc" SELECTED>Codice [A-Z]</option>
												<option value="product.code-desc">Codice [Z-A]</option>
												<option value="product.name-asc">Descrizione [A-Z]</option>
												<option value="product.name-desc">Descrizione [Z-A]</option>
											</select>
										</div>

										<div class="align-self-end d-flex">
											#searchButton( bind = "click:search", class="me-1" )#

											<div class="dropdown">
												<button class="btn btn-default dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
													Report
												</button>
												<ul class="dropdown-menu">
													<li><a class="dropdown-item hand" data-bind="click:print" data-report="bill-of-material">Distinta base</a></li>
												</ul>
											</div>

										</div>
									</form>
								</div>
							</div>

						</div>

						<form name="product-grid-form" id="product-grid-form" method="post">
							<div class="col-12">
								#grid(
									id      = "product-grid",
									columns = "[
                                        { 'field':'shortId', 'title':'ID', width: '80px' },
                                        { 'field':'category.id', 'title':'Categoria' },
                                        { 'field':'line.name', 'title':'Linea' },
                                        { 'field':'model.name', 'title':'Modello'},
                                        { 'field':'finish.name', 'title':'Finitura'},
                                        { 'field':'prices', 'title':'Prezzi'},
                                        { 'field':'', 'title':'Attributi', width: '55px'}
                                    ]",
									rowTemplate = "product/product-grid-row-tmpl"
								)#
							</div>
						</form>
					</div>
				</section>
			</div>
		</div>

	</div>

	#view( "price/list-modal" )#

</cfoutput>
