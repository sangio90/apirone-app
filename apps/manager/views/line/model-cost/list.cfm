<cfoutput>

	<div id="line-model-cost-list-root">

		<div class="row">
			<div class="col-6">
				#pageTitle()#
			</div>
		</div>

		<div class="row">

			<div class="col-lg-12">
				<section class="card">
					<div class="card-body">

						<p class="text-muted small mb-3">
							Costo fisso ripartito nel preventivo su tutte le placche/segnaletiche della stessa linea e modello, di qualsiasi finitura.
							Si somma all'eventuale costo per linea/finitura.
						</p>

						<div class="row d-flex align-items-center mb-3">
							<div class="col-sm-12">
								<div class="box-search-small">
									<form id="line-model-cost-search-form" class="d-flex align-items-center justify-content-end">

										<div class="col-4 pe-1">
											<span>Categoria</span>
											<select class="form-control me-2" name="categoryId"
												data-role="combobox"
												data-placeholder="-- Seleziona categoria"
												data-bind="source: categories, value: search.categoryId, events: { change: onSearchCategoryChange }"
												data-value-primitive="true"
												data-value-field="id"
												data-text-field="name"
												data-filter="contains">
											</select>
										</div>

										<div class="col-3 pe-1">
											<span>Linea</span>
											<select class="form-control" name="lineId"
												data-role="combobox"
												data-placeholder="-- Seleziona linea"
												data-bind="source: searchLines, value: search.lineId, events: { change: onSearchLineChange }"
												data-value-primitive="true"
												data-value-field="id"
												data-text-field="name"
												data-filter="contains">
											</select>
										</div>

										<div class="col-3 pe-1">
											<span>Modello</span>
											<select class="form-control" name="modelId"
												data-role="combobox"
												data-placeholder="-- Seleziona modello"
												data-bind="source: searchModels, value: search.modelId"
												data-value-primitive="true"
												data-value-field="id"
												data-text-field="name"
												data-filter="contains">
											</select>
										</div>

										<div class="col-1 pe-1">
										</div>

										<div class="align-self-end d-flex">
											#searchButton( bind = "click:doSearch", class="me-1" )#
										</div>
									</form>
								</div>
							</div>
						</div>

						<form name="line-model-cost-grid-form" id="line-model-cost-grid-form" method="post">

							<div class="text-end mb-2">
								<button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="##lineModelCostAddModal">
									Aggiungi costo
								</button>
							</div>

							<div class="col-12">
								#grid(
									id      = "line-model-cost-grid",
									columns = "[
										{ 'field':'category.name', 'title':'Categoria' },
										{ 'field':'line.name', 'title':'Linea' },
										{ 'field':'model.name', 'title':'Modello'},
										{ 'field':'cost', 'title':'Costo', 'width': '150px' },
										{ 'field':'', 'title':'', 'width': '200px' }
									]",
									rowTemplate = "line/line-model-cost-grid-row-tmpl"
								)#
							</div>
						</form>
					</div>
				</section>
				<div class="modal fade" id="lineModelCostAddModal" tabindex="-1" aria-hidden="true">
					<div class="modal-dialog">
						<div class="modal-content">

						<div class="modal-header">
							<h5 class="modal-title">Aggiungi costo linea/modello</h5>
							<button type="button" class="btn-close" data-bs-dismiss="modal"></button>
						</div>

						<div class="modal-body">
							<form id="line-model-cost-add-form">

							<div class="mb-3">
								<label class="form-label">Categoria</label>
								<select class="form-control me-2"
									data-role="combobox"
									data-placeholder="-- Seleziona categoria"
									data-bind="source: categories, value: form.categoryId, events: { change: onFormCategoryChange }"
									data-value-primitive="true"
									data-value-field="id"
									data-text-field="name"
									data-filter="contains">
								</select>
							</div>

							<div class="mb-3">
								<label class="form-label">Linea</label>
								<select class="form-control"
									data-role="combobox"
									data-placeholder="-- Seleziona linea"
									data-bind="source: formLines, value: form.lineId, events: { change: onFormLineChange }"
									data-value-primitive="true"
									data-value-field="id"
									data-text-field="name"
									data-filter="contains">
								</select>
							</div>

							<div class="mb-3">
								<label class="form-label">Modello</label>
								<select class="form-control"
									data-role="combobox"
									data-placeholder="-- Seleziona modello"
									data-bind="source: formModels, value: form.modelId"
									data-value-primitive="true"
									data-value-field="id"
									data-text-field="name"
									data-filter="contains">
								</select>
							</div>

							<div class="mb-3">
								<label class="form-label">Costo</label>
								<input class="form-control" data-bind="value: form.cost">
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
