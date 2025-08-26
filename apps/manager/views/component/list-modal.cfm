<cfoutput>
	
	<div id="component-list-modal" class="modal fade">

		<section class="modal-dialog modal-xl">
			<div class="modal-content">
				
				<header class="card-header d-flex align-elements-center justify-content-between modal-header--sticky">
					<h2 class="card-title"><span data-bind="text: getModalTitle"></span></h2>
					<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Chiudi">
				</header>

				<div class="card-body">
					<div class="row">

						<div class="col-5">

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
											<option value="">-- tutte</option>
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

							#view( "component/component-list-variant" )#
						
						</div>

						<div class="col-7">

							<form id="component-list-selected-form" class="row">

								<div class="col-12">
									<div class="row">
										<div class="col-6">
											<h4>Componenti selezionati</h4>
										</div>
										<div class="col-6 mt-2 text-end fs-11" id="components-status-selected">
										</div>
									</div>
								</div>	

								<div class="col-10">
									<div class="pb-2 d-flex align-items-center justify-content-start mb-2">

										<input
											id = "component-search-selected-input"
											placeholder = "Filtra..." 
											class = "form-control me-3 form-control-sm"
											name = "str"
											style = "width:50%"
										>

										<select class="form-control me-3 form-control-sm" name="processingTypeId" style="width:53%">
											<option value="">-- tutte le tipologie</option>
											<option value="MP">Materie prime</option>
											<option value="LV">Lavorazioni</option>
										</select>

										#iconButton( bind="click:filterSelected", icon="search", variant="primary", size="sm" )#
										#iconButton( bind="click:resetFilterSelected", icon="times", variant="default", size="sm", class="ms-3" )#

									</div>
								</div>

								<div class="col-2 text-end">
									#iconButton( bind="click:copy", icon="copy", variant="default", size="sm", class="me-2", title="Copia le righe selezionate" )#
									#iconButton( bind="click:paste", icon="paste", variant="default", size="sm", title="Incolla le righe selezionate" )#
								</div>

								<div class="col-12">

									<div class="fs-11 text-end mb-1"><a href="##" data-bind="click:selectAll">Seleziona tutto</a></div>

									#table( source="selected", rowTemplate="component/component-selected-row-tmpl" )#

									<div class="pt-5" data-bind="invisible: showSelectedTable">
										<p class="text-center">Nessun componente ancora selezionato</p>
									</div>

								</div>
							
							</form>

						</div>

					</div>
				</div>

				<footer class="card-footer modal-footer--sticky">
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

	<!--- #template( "jstemplate/component/component-selected-row-tmpl" )# ---->

</cfoutput>
