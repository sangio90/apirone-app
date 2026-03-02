<cfoutput>
	
	<div id="line-cost-list-root">

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
							<div class="col-sm-12">
								<div class="box-search-small">
									<form id = "line-cost-search-form" class = "d-flex align-items-center justify-content-end">
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
											<span>Finitura</span>
											<select class="form-control me-2" name="finishId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.finishes#" item="item">
													<option value="#item.getId()#">#item.getName()# (#item.getCode()#)</option>
												</cfloop>
											</select>
										</div>

										<div class="align-self-end d-flex">
											#searchButton( bind = "click:search", class="me-1" )#
										</div>
									</form>
								</div>
							</div>
						</div>

						<form name="line-cost-grid-form" id="line-cost-grid-form" method="post">

							<div class="text-end mb-2">
								<button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="##lineCostAddModal">
									Aggiungi costo
								</button>
							</div>

							<div class="col-12">
								#grid(
									id      = "line-cost-grid",
									columns = "[
                                        { 'field':'category.name', 'title':'Categoria' },
                                        { 'field':'line.name', 'title':'Linea' },
                                        { 'field':'finish.name', 'title':'Finitura'},
                                        { 'field':'cost', 'title':'Costo', 'width': '150px' },
                                        { 'field':'', 'title':'', 'width': '200px' }
                                    ]",
									rowTemplate = "line/line-cost-grid-row-tmpl"
								)#
							</div>
						</form>
					</div>
				</section>
				<div class="modal fade" id="lineCostAddModal" tabindex="-1" aria-hidden="true">
					<div class="modal-dialog">
						<div class="modal-content">

						<div class="modal-header">
							<h5 class="modal-title">Aggiungi costo linea</h5>
							<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
						</div>

						<div class="modal-body">
							<form id="line-cost-add-form">

							<div class="mb-3">
								<label class="form-label">Categoria</label>
								<select class="form-control" name="category_id">
								<option value="">-- tutte</option>
								<cfloop array="#prc.categories#" item="item">
									<option value="#item.getId()#">#item.getName()#</option>
								</cfloop>
								</select>
							</div>

							<div class="mb-3">
								<label class="form-label">Linea</label>
								<select class="form-control" name="line_id">
								<option value="">-- tutte</option>
								<cfloop array="#prc.lines#" item="item">
									<option value="#item.getId()#">#item.getName()#</option>
								</cfloop>
								</select>
							</div>

							<div class="mb-3">
								<label class="form-label">Finitura</label>
								<select class="form-control" name="finish_id">
								<option value="">-- tutte</option>
								<cfloop array="#prc.finishes#" item="item">
									<option value="#item.getId()#">#item.getName()# (#item.getCode()#)</option>
								</cfloop>
								</select>
							</div>

							<div class="mb-3">
								<label class="form-label">Costo</label>
								<input class="form-control" name="cost">
							</div>

							</form>
						</div>

						<div class="modal-footer">
							<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
							Annulla
							</button>
							<button type="button" class="btn btn-primary" data-bind="click:create">
							Salva
							</button>
						</div>

						</div>
					</div>
				</div>
			</div>
		</div>

	</div>

</cfoutput>
