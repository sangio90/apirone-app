<cfoutput>
	<div id="component-list-modal" class="modal fade">
		<section class="modal-dialog modal-xl">
			<div class="modal-content">
				<header class="card-header">
					<h2 class="card-title">Cerca componenti da Verticale</h2>
				</header>

				<div class="card-body">
					<div class="row">
						
						<div class="col-6">

							<div data-bind="visible: showSearchPanel">
								<form data-bind="events: { submit: search }" id="component-list-search-form">

									<div class="pb-2 d-flex align-items-center justify-content-start">

										<input
											id="component-search-input"
											placeholder="Cerca..." 
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
                                                    { 'field':'', 'title':'', width: '110px'},
                                                ]",
												source      = "components",
												rowTemplate = "component/component-row-list-tmpl"
											)#
										</div>
									</div>
								</form>
							</div>

							#view( "component/component-list-variant" )#
						
						</div>

						<div class="col-6">

							<table class="table table-hover pt-5">
								<thead>
									<tr>
										<th scope="col" colspan="3">Componenti selezionati per <span data-bind="text: getCurrentItemName"></span></th>
										<th scope="col" width="50"></th>
									</tr>
								</thead>
								<tbody data-bind="source:selected" data-template="component-selected-row-tmpl">
								</tbody>
							</table>

							<div class="pt-5" data-bind="invisible: showSelectedComponentTable">
								<p class="text-center">Nessun componente ancora selezionato</p>
							</div>

						</div>

					</div>
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
	</div>

	#template( "jstemplate/component/component-selected-row-tmpl" )#

</cfoutput>
