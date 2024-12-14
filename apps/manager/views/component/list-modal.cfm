<cfoutput>
	<div id="component-list-modal"> <!--- class="modal fade" ---->

		<!-----

		<section class="modal-dialog modal-xl">
			<div class="modal-content">
				<header class="card-header">
					<h2 class="card-title">Componenti per <span data-bind="text: getCurrentItemName"></span></h2>
				</header>

				<div class="card-body">
					------->
					<div class="row">

						<div class="col-12">

							<div data-bind="visible: showSearchPanel">

								<form data-bind="events: { submit: search }" id="component-list-search-form">

									<div class="pb-2 d-flex align-items-center justify-content-start box-search-small">

										<input
											id="component-search-input"
											placeholder="Cerca in Verticale..." 
											class      ="form-control me-3"
											name       ="str"
										>

										<select class="form-control me-3" name="processingTypeId" style="width:46%">
											<option value="MP">Materie prime</option>
											<option value="LV">Lavorazioni</option>
										</select>

										#iconButton( bind="click:search", icon="search", variant="primary" )#

									</div>

									<div class="pb-2">
										<div class="status">
											Fai una ricerca
										</div>
									</div>
								</form>

								<form id="component-list-search-result-form" class="row">
									
									<div class="col-md-12">
										<div data-bind="visible: showSearchResult">
											#grid(
												id      = "component-list-grid",
												columns = "[
													{ 'field':'name', 'title':'Lavorazione/Materia prima'},
													{ 'field':'', 'title':'', width: '42px' },
												]",
												source      = "components",
												rowTemplate = "component/component-row-list-tmpl"
											)#
										</div>
									</div>
								</form>
							
							</div>

							<!---- #view( "component/component-list-variant" )# ---->
						
						</div>

						<!----
						<div class="col-6">

							<form id="component-list-selected-form" class="row">

								<div class="col-12">

									<h4>Componenti selezionati</h4>

									<div class="pb-2 d-flex align-items-center justify-content-start mb-2">

										<input
											id="component-search-selected-input"
											placeholder="Filtra..." 
											class      ="form-control me-3 form-control-sm"
											name       ="str"
										>

										<select class="form-control me-3 form-control-sm" name="processingTypeId" style="width:46%">
											<option value="MP">Materie prime</option>
											<option value="LV">Lavorazioni</option>
										</select>

										#iconButton( bind="click:filterSelected", icon="search", variant="primary", size="sm" )#

									</div>


									<table class="table table-hover pt-5">
										<tbody data-bind="source:selected" data-template="component-selected-row-tmpl">
										</tbody>
									</table>

									<div class="pt-5" data-bind="invisible: showSelectedTable">
										<p class="text-center">Nessun componente ancora selezionato</p>
									</div>

									<p>#saveButton(bind="click:save", size="sm")#</p>

								</div>
							
							</div>

						</div>
						---->

					</div>
					<!----
				</div>

				<footer class="card-footer">
					<div class="row">
						<div class="col-md-12 text-end">
							<button type="button" class="btn btn-default btn-sm me-2" data-bs-dismiss="modal">Chiudi</button>

							#saveButton(bind="click:save", size="sm")#

						</div>
					</div>
				</footer>
			</div>
		</section>
		----->
	</div>

	#template( "jstemplate/component/component-selected-row-tmpl" )#

</cfoutput>
