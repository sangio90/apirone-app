<cfoutput>
<div class="pricing-box" id="#args.id#">
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
		<div class="col-6">
			<select name="priceMethod" class="form-control" id="input-price-method"
				data-role="dropdownlist"
				data-bind="source: pricing.priceTypes, value: pricing.data.method.id, events: { change: changeMethod }"
				data-value-field="id"
				data-text-field="name"
				>
			</select>
		</div>
		<div class="col-6">
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


</cfoutput>