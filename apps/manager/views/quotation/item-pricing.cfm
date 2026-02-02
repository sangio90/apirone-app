<cfoutput>
	<div class="h-100">

		<div class="row">

			<div class="col-6">
				<div class="mb-1">Speciale:</div>
				<div>
					<input class="form-check-input" type="checkbox"
						name="special" 
						data-bind="value: detailForm.data.special">
				</div>
			</div>

			<div class="col-6 mb-2">

				<div class="mb-1">Stato:</div>
				<div>
					<select name="status" class="form-control form-control-sm" id="input-price-status"
						data-bind="value: detailForm.data.status"
						data-value-field="id"
						data-text-field="name"
						>
						<option value="ACT" SELECTED>Attivo</option>
						<option value="BLK">Bloccato</option>
						<option value="IGN">Ignora</option>
					</select>
				</div>
			</div>

			<div class="col-12">
				<div class="row mb-2">
					<div class="col-4 mt-2">Posizione:</div>
					<div class="col-8">
						<input class="form-control form-control-sm" name="position" 
							placeholder="Posizione" data-bind="value: detailForm.data.position.code">
					</div>
				</div>
			</div>

			<div class="col-12 mb-2">
				<textarea class="form-control" name="notes" placeholder="Note" rows="4"
					data-bind="value: detailForm.data.note"></textarea>
			</div>

		</div>

		<cffile action="append" file="#ExpandPath('/debug.log')#" output="#SerializeJSON(args)#">

		<div>
			<div class="pricing-box" id="#args.id#">

				<div class="row mb-2">
					<div class="col-4 mt-2">Quantità</div>
					<div class="col-8">
						<input class="form-control form-control" name="quantity" 
							data-bind="value: pricing.data.quantity">
					</div>
				</div>

				<div class="row mb-2">
					<div class="col-12">
						<table style="width: 100%" class="quotation-table-item-prices-totals">
							<tbody data-bind="source: pricing.data.lines" 
								data-template="quotation-pricing-totals-item-tmpl"></tbody>
						</table>
					</div>
				</div>

				<div class="row mb-2">
					<div class="col-4 mt-2">Sconti</div>
					<div class="col-4">
						<input class="form-control" name="discount1" 
							placeholder="%" data-bind="value: pricing.data.discount1">
					</div>
					<div class="col-4">
						<input class="form-control" name="discount2" 
							placeholder="%" data-bind="value: pricing.data.discount2">
					</div>
				</div>

				<div class="row mb-2">
					<div class="col-12">
						Totale:
					</div>
				</div>

				<div class="row mb-2">
					<div class="col-5">
						<select name="priceMethod" class="form-control" id="input-price-method"
							data-bind="value: pricing.data.method, events: { change: changeMethod }"
							data-value-field="id"
							data-text-field="name"
							>
							<option value="C">Calcolato</option>
							<option value="F">Fisso</option>
						</select>
					</div>
					<div class="col-7">
						<div class="input-group">
							<input class="form-control text-end" name="total" id="input-item-total"
								placeholder="Totale"
								data-format="0.00"
								data-bind="value: pricing.data.total">
							<span class="input-group-text">
								<i class="fas fa-euro-sign"></i>
							</span>
						</div>
					</div>
				</div>

				<div class="row mb-2 mt-2">
					<div class="col-12 d-flex align-items-center">
						#button(bind="click:update", size="sm", icon="sync", class="mt-3", label="Aggiorna prezzi")#
						<div class="ms-2 mt-3 status" id="quotation-item-pricing-status"></div>
					</div>
				</div>

			</div>
		</div>

	</div>
</cfoutput>