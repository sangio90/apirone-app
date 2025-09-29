<cfoutput>
    <div id="price-manage-root">

        <div class="row">
            <div class="col-6 pt-2">
				#pageTitle()#
            </div>
        </div>

        <div class="row">
			<div class="col-lg-12">

				<section class="card">

					<div class="card-title">
						<h5>Aggiorna prezzi e costi</h5>
					</div>
				
					<div class="card-body">
						
						<div class="row mb-3">
							
							<div class="col-sm-12">
								<form
									id   ="price-manage-grid-search-form"
									data-bind: 'events: { submit: search }'>

									<div class="mb-3 row">
										<label class="col-sm-2 col-form-label text-end">Categoria</label>
										<div class="col-sm-10">
											<select class="form-control me-2 col-sm-8" name="categoryId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.categories#" item="item">
													<option value="#item.getId()#">#item.getName()#</option>
												</cfloop>
											</select>
										</div>
									</div>

									<div class="mb-3 row">
										<label class="col-sm-2 col-form-label text-end">Linea</label>
										<div class="col-sm-10">
											<select class="form-control me-2" name="lineId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.lines#" item="item">
													<option value="#item.getId()#">#item.getName()#</option>
												</cfloop>
											</select>
										</div>
									</div>									

									<div class="mb-3 row">
										<label class="col-sm-2 col-form-label text-end">Modello</label>
										<div class="col-sm-10">
											<select class="form-control me-2" name="modelId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.models#" item="item">
													<option value="#item.getId()#">#item.getName()# (#item.getCode()#)</option>
												</cfloop>
											</select>
										</div>
									</div>

									<div class="mb-3 row">
										<label class="col-sm-2 col-form-label text-end">Finitura</label>
										<div class="col-sm-10">
											<select class="form-control me-2" name="finishId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.finishes#" item="item">
													<option value="#item.getId()#">#item.getName()# (#item.getCode()#)</option>
												</cfloop>
											</select>
										</div>
									</div>

									<div class="mb-3 row">
										<label class="col-sm-2 col-form-label text-end">Status</label>
										<div class="col-sm-10">
											<select class="form-control me-2" name="statusId">
												<option value="">-- tutti</option>
												<cfloop array="#prc.statuses#" item="item">
													<option value="#item.getId()#">#item.getName()#</option>
												</cfloop>
											</select>
										</div>
									</div>

									<div class="mb-3 row">
										<label class="col-sm-2 col-form-label text-end">Tipo prezzo</label>
										<div class="col-sm-10">
											<select class="form-control me-2" name="statusId" required> 
												<option value="">-- seleziona un tipo</option>
												<cfloop array="#prc.types#" item="item">
													<option value="#item.getId()#">#item.getName()#</option>
												</cfloop>
											</select>
										</div>
									</div>

									<div class="mb-3 row">
										
										<label class="col-sm-2 col-form-label text-end">Imposta</label>

										<div class="col-sm-3 d-flex align-items-center">
											<div class="me-2">Tipo prezzo:</div>
											<select class="form-control" name="priceMethodId">
												<option>Invariato</option>
												<option>%</option>
												<option>Fisso</option>
											</select>
										</div>
										
										<div class="col-sm-3 d-flex align-items-center">
											<div class="me-2">Nuovo valore</div>
											<input type="text" class="form-control" name="amount" required />
										</div>
										
										<div class="col-sm-3 d-flex align-items-center">
											<div class="me-2">calcola sul valore esistente... </div>
											<select class="form-control" name="priceMethodId">
												<option>Sostituisci</option>
												<option>Variazione in percentuale</option>
											</select>
										</div>

										<div class="col-sm-3 d-flex align-items-center">
											<div class="me-2">Variazione</div>
											<input type="text" class="form-control" name="amount" required />
										</div>

										<div class="col-sm-3 d-flex align-items-center">
											<div class="me-2">Metodo</div>
											<select class="form-control" name="methodId">
												<option>%</option>
												<option>Fisso</option>
											</select>
										</div>
									
									</div>

									<div class="mb-3 row">
										<label class="col-sm-2"></label>
										<div class="col-sm-10">
											#saveButton( bind = "click:save", class="me-1" )#
										</div>
									</div>
								</form>
							</div>

						</div>

					</div>

				</section>

			</div>
		</div>
    </div>
</cfoutput>