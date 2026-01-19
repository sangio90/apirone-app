<cfoutput>
	<div class="pricing-box h-100">

		<div class="row mb-2">

			<div class="col-6">
				<div class="mb-1">Stato:</div>
				<div>
					<select name="status" class="form-control form-control-sm" id="input-price-status"
						data-bind="value: detailForm.data.status"
						data-value-field="id"
						data-text-field="name"
						>
						<option value="ACT" SELECTED>Attivo</option>
						<option value="BLK">Bloccato</option>
					</select>
				</div>
			</div>

			<div class="col-6">
				<div class="mb-1">Posizione:</div>
				<div>
					<input class="form-control form-control-sm" name="position" 
						placeholder="Posizione" data-bind="value: detailForm.data.position.code">
				</div>
			</div>

		</div>

		<div class="row mb-2">

			<div class="col-12">
				<div class="mb-1">Speciale:</div>
				<div>
					<input class="form-check-input" type="checkbox"
						name="special" 
						data-bind="value: detailForm.data.special">
				</div>
			</div>
		
		</div>

		<div class="row mb-2">
			<div class="col-4 mt-2">Sconti</div>
			<div class="col-4">
				<input class="form-control" name="discount1" 
					placeholder="%" data-bind="value: detailForm.data.pricing.discount1">
			</div>
			<div class="col-4">
				<input class="form-control" name="discount2" 
					placeholder="%" data-bind="value: detailForm.data.pricing.discount2">
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
					data-bind="value: detailForm.data.pricing.method, events: { change: changeMethod }"
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
						data-bind="value: detailForm.data.pricing.total">
					<span class="input-group-text">
						<i class="fas fa-euro-sign"></i>
					</span>
				</div>
			</div>
		</div>

	</div>
</cfoutput>