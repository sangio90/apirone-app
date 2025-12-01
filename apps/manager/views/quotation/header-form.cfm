<cfoutput>

	<div>

		<nav>
			<div class="nav nav-tabs" id="nav-tab" role="tablist">
				<button class="nav-link active" id="nav-general-tab" data-bs-toggle="tab" data-bs-target="##nav-general" type="button" role="tab">Dati generali</button>
				<button class="nav-link" id="nav-billing-tab" data-bs-toggle="tab" data-bs-target="##nav-billing" type="button" role="tab">Indirizzo di Fatturazione</button>
				<button class="nav-link" id="nav-shipment-tab" data-bs-toggle="tab" data-bs-target="##nav-shipment" type="button" role="tab">Indirizzo di Spedizione</button>
				<button class="nav-link" id="nav-fiscal-tab" data-bs-toggle="tab" data-bs-target="##nav-fiscal" type="button" role="tab">Dati fiscali</button>
				<!--- <button class="nav-link" id="nav-discount-tab" data-bs-toggle="tab" data-bs-target="##nav-discount" type="button" role="tab">Sconti/Costi</button> --->
				<!--- <button class="nav-link" id="nav-assignment-tab" data-bs-toggle="tab" data-bs-target="##nav-assignment" type="button" role="tab">Assegnatario</button> --->
				<!--- <button class="nav-link" id="nav-plan-tab" data-bs-toggle="tab" data-bs-target="##nav-plan" type="button" role="tab" hidden>Planimentria</button> --->
				<!--- <button class="nav-link" id="nav-shipments-tab" data-bs-toggle="tab" data-bs-target="##nav-shipments" type="button" role="tab" hidden>Spedizioni</button> --->
			</div>
		</nav>
		<div class="tab-content" id="nav-tabContent">

			<!---
				general
			--->
			<div class="tab-pane quotation-panel fade show active row" id="nav-general" role="tabpanel">

				<div class="col-6 co-md-12">

					<div class="row d-flex align-items-center mb-3">
						<label class="col-3 text-end">Lingua </label>
						<div class="col-9">
							<select name="langId" class="form-control"
								data-bind="source: languages, value: detailForm.data.lang"
								data-value-field="id"
								data-text-field="name"
								required
							>
							</select>
						</div>
					</div>

					<div class="row d-flex align-items-center mb-3">
						<label class="text-end col-3">Cliente </label>
						<div class="col-9">
							<input type="text" name="customer" class="form-control" id="qt-customer"
								data-bind="source: crmCustomers, value: detailForm.data.customer"
								data-text-field="name"								
								data-role="autocomplete"
								data-value-primitive="false"
								data-minlength="4"
								data-filter="contains">
						</div>
					</div>

					<div class="row d-flex align-items-center mb-3">
						<label class="text-end col-3">Opportunità</label>
						<div class="col-9">
							<input type="text" name="opportunity" class="form-control" id="qt-opportunity"
								data-bind="source: crmOpportunities, value: detailForm.data.opportunity"
								data-role="autocomplete"
								data-text-field="name"
								data-value-primitive="false"
								data-minlength="4"
								data-filter="contains"
							>
						</div>
					</div>

					<div class="row d-flex align-items-center mb-3">
						<label class="text-end col-3">Lead</label>
						<div class="col-9">
							<input type="text" name="lead" class="form-control" id="qt-lead"
								data-bind="source: crmLeads, value: detailForm.data.lead"
								data-role="autocomplete"
								data-text-field="name"
								data-value-primitive="false"
								data-minlength="4"
								data-filter="contains"
							>
						</div>
					</div>

					<div class="row d-flex align-items-center">
						<label class="text-end col-3"></label>
						<div class="col-9">
							<input type="hidden" name="requireAnyOfCustomerLeadOrOpportunity">
						</div>
					</div>

					<div class="row d-flex align-items-center mb-3">
						<label class="text-end col-3">Data documento</label>
						<div class="col-9">
							<input type="date" class="form-control" 
								data-bind="value: detailForm.data.quotationDate">
						</div>
					</div>

					<div class="row d-flex align-items-center mb-3">
						<label class="text-end col-3">Data validità</label>
						<div class="col-9">
							<input type="date" class="form-control" 
								data-bind="value: detailForm.data.validityDate">
						</div>
					</div>

					<div class="row d-flex align-items-center mb-3">
						<label class="text-end col-3">Nota</label>
						<div class="col-9">
							<textarea name="note" class="form-control" rows="2" 
								data-bind="value: detailForm.data.notes">
							</textarea>
						</div>
					</div>

				</div>

			</div>

			<!---
				billing
			--->
			<div class="tab-pane quotation-panel fade" id="nav-billing" role="tabpanel">

				<div class="row">
					<div class="col-6">

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Nome</label>
							<div class="col-9">
								<input type="text" class="form-control" data-bind="value: detailForm.data.customer.name" readonly>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Ragione sociale</label>
							<div class="col-9">
								<input type="text" class="form-control" data-bind="value: detailForm.data.customer.company" readonly>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Partita Iva</label>
							<div class="col-9">
								<input type="text" class="form-control" data-bind="value: detailForm.data.customer.vatNumber" readonly>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Telefono</label>
							<div class="col-9">
								<input type="text" class="form-control" data-bind="value: detailForm.data.customer.phone" readonly>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Indirizzo</label>
							<div class="col-9">
								<input type="text" class="form-control" data-bind="value: detailForm.data.customer.street" readonly>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Città</label>
							<div class="col-9">
								<input type="text" class="form-control" data-bind="value: detailForm.data.customer.city" readonly>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">CAP</label>
							<div class="col-9">
								<input type="text" class="form-control" data-bind="value: detailForm.data.customer.postalCode" readonly>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Nazione</label>
							<div class="col-9">
								<input type="text" class="form-control" data-bind="value: detailForm.data.customer.country" readonly>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Provincia</label>
							<div class="col-9">
								<input type="text" class="form-control" data-bind="value: detailForm.data.customer.state" readonly>
							</div>
						</div>                                            

					</div>
				</div>

			</div>

			<!---
				shipment
			--->
			<div class="tab-pane quotation-panel fade" id="nav-shipment" role="tabpanel">

				<div class="row">
					<div class="col-6">

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Indirizzo</label>
							<div class="col-9">
								<select class="form-control"
									data-bind="source: detailForm.data.customer.shippingAddresses, value: detailForm.data.shippingAddress"
									data-value-field="id"
									data-text-field="name"
								>
								</select>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Indirizzo</label>
							<div class="col-9">
								<input type="text" class="form-control" data-bind="value: detailForm.data.shippingAddress.via" disabled>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Città</label>
							<div class="col-9">
								<input type="text" class="form-control" data-bind="value: detailForm.data.shippingAddress.citta" disabled>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">CAP</label>
							<div class="col-9">
								<input type="text" class="form-control" data-bind="value: detailForm.data.shippingAddress.cap" disabled>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Nazione</label>
							<div class="col-9">
								<input type="text" class="form-control" data-bind="value: detailForm.data.shippingAddress.paese" disabled>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Provincia</label>
							<div class="col-9">
								<input type="text" class="form-control" data-bind="value: detailForm.data.shippingAddress.provincia" disabled>
							</div>
						</div>                                            
						
					</div>

				</div>
				
			</div>

			<!---
				dati fiscali
			--->
			<div class="tab-pane fade" id="nav-fiscal" role="tabpanel">

				<div class="row mb-3">

					<div class="col-6">

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Pagamento</label>
							<div class="col-9">
								<select name="paymentMethod" class="form-control"
									data-bind="source: paymentMethods, value: detailForm.data.paymentMethod"
									data-value-field="id"
									data-text-field="name"
								>
								</select>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Aliquota IVA</label>
							<div class="col-9">
								<select name="paymentMethod" class="form-control"
									data-bind="source: vatCodes, value: detailForm.data.vatCode"
									data-value-field="id"
									data-text-field="name">
								</select>
							</div>
						</div>

						<div class="form-group row mb-3">
							<label class="col-3 control-label text-sm-end pt-2">Valuta</label>
							<div class="col-9">
								<select name="currency" class="form-control"
									data-bind="source: currencies, value: detailForm.data.currency"
									data-value-field="id"
									data-text-field="name">
								</select>
							</div>
						</div>
					
					</div>

				</div>

			</div>

			<!---
				assignment
			--->
			<div class="tab-pane fade" id="nav-assignment" role="tabpanel">

				<div class="form-group row mb-3">
					<label class="col-sm-3 control-label text-sm-end pt-2">Commerciale</label>
					<div class="col-sm-9">
						<select name="statusId" class="form-control">
							<option value="">-- selezionare</option>
							<option value="REF">22%</option>
						</select>
					</div>
				</div>

			</div>
		
		</div>

	</div>

</cfoutput>				