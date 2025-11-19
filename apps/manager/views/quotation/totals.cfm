<cfoutput>
	<div id="totalsFloatingTab" class="container py-3">
		<div>
			<div class="flex" style="width: 100%">
				<div class="justify-content-start" style="width: 95%">
					<h3>Totali</h3>
				</div>
				<div style="font-size: 1.5em; cursor: pointer" id="symbol" data-bind="click: collapseTotals">▼</div>
			</div>
			<div id="totalsFloatingTabContent">
				<table style="width: 100%" class="quotation-table-item-prices-totals">
					<tbody data-bind="source: pricing.lines" data-template="quotation-pricing-totals-item-tmpl"></tbody>
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
						#button(bind="click:update", variant="default", label="Aggiorna", size="sm", icon="sync-alt")#
					</div>
				</div>
			</div>
		</div>
	</div>
</cfoutput>