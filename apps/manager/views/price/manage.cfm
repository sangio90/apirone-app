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
								<form id="price-manage-search-form">

									<div class="mb-3 row">
										<label class="col-sm-2 col-form-label text-end">Categoria</label>
										<div class="col-sm-10">
											<select class="form-control me-2 col-sm-8" name="categoryId" required>
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
											<select class="form-control me-2" name="lineId" required>
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
										
										<label class="col-sm-2 col-form-label text-end">Aggiorna</label>

										<div class="col-sm-10">

											<div class="row">

												<div class="col-sm-4">
													<div class="me-2">Tipo:</div>
													<select class="form-control" name="typeId" required>
														<option value="">-- seleziona</option>
														<cfloop array="#prc.types#" item="item">
															<option value="#item.getId()#">#item.getName()#</option>
														</cfloop>
													</select>
												</div>
												
												<div class="col-sm-4">
													<div class="me-2">Nuovo metodo:</div>
													<select class="form-control" name="newMethodId">
														<option value="P">%</option>
														<option value="F">Fisso</option>
													</select>
												</div>
												
												<div class="col-sm-4">
													<div>Nuovo importo:</div>
													<input type="text" class="form-control" name="newAmount" required />
												</div>

											</div>

										</div>

										
										<!---
										TODO: add more options, e.g. modify current value by percentage
										<div class="col-sm-3 d-flex align-items-center">
											<div class="me-2">calcola sul valore esistente... </div>
											<select class="form-control" name="priceMethodId">
												<option>Sostituisci</option>
												<option>Variazione in percentuale</option>
											</select>
										</div>
										---->
									
									</div>

									<div class="mb-3 row">
										<label class="col-sm-2"></label>
										<div class="col-sm-10 d-flex align-items-center">
											#saveButton( bind = "click:save", class="me-1" )#
											<div class="ms-2 status"></div>
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