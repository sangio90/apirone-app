<cfoutput>
	<div id="totalsFloatingTab" class="container py-3">
		<div>
			<h3>Totali</h3>
			<table style="width: 100%" style="">
				<tbody data-bind="source: pricing.items" data-template="quotation-pricing-totals-item-tmpl"></tbody>
			</table>
			<div class="row mt-3 mb-2">
				<div class="col-4">Sconti</div>
				<div class="col-4"><input class="form-control" name="discount1" placeholder="%" data-bind="value: pricing.discounts.value1"></div>
				<div class="col-4"><input class="form-control" name="discount2" placeholder="%" data-bind="value: pricing.discounts.value1"></div>
			</div>
			<div class="row mt-3 mb-2">
				<div class="col-6">
					<select name="priceType" class="form-control" data-bind="value: pricing.priceType.id">
						<option value="C">Prezzo calcolato</option>
						<option value="F">Prezzo fisso</option>
					</select>
				</div>
				<div class="col-6">
					<input class="form-control" name="total"  data-bind="value: pricing.total" placeholder="Totale preventivo">
				</div>
			</div>
			<div class="d-flex justify-content-end gap-2">
				<div class="py-2 text-end">
					#saveButton(bind="click:update", variant="default", label="Aggiorna", size="sm")#
				</div>
			</div>
		</div>
	</div>
</cfoutput>