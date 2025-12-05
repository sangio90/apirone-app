<cfoutput>
	<div id="quotation-totals" class="container py-3 quotation-totals-box">
		<div>
			<div class="flex" style="width: 100%">
				<div class="justify-content-start" style="width: 95%" id="qt-totals-title">
					<h3 data-bind="text: common.title"></h3>
				</div>
				<div style="font-size: 1.5em; cursor: pointer" 
					id="qt-item-totals-symbol" data-bind="click:collapseTotals, text:common.symbol"></div>
			</div>

			<div class="quotation-totals-content" id="quotation-totals-content" data-bind="invisible:common.isCollapsed">
			
				<!--- 
					quotation item princing
				--->
				<div id="quotation-totals-item-content" data-bind="visible: isItem">
					<table style="width: 100%" class="quotation-table-item-prices-totals">
						<tbody data-bind="source: pricing.data.lines" 
							data-template="quotation-pricing-totals-item-tmpl"></tbody>
					</table>
					<div class="row mt-3 mb-2 align-items-center d-flex">
						<div class="col-4">Sconti</div>
						<div class="col-4">
							<input class="form-control" name="discount1" 
								placeholder="%" data-bind="value: pricing.data.discount1">
						</div>
						<div class="col-4">
							<input class="form-control" name="discount2" 
								placeholder="%" data-bind="value: pricing.data.discount2">
						</div>
					</div>
					<div class="row mt-3 mb-2">
						<div class="col-6">
							<select name="priceMethod" class="form-control" 
								data-bind="value: pricing.data.method.id, events: { change: changeMethod }">
								<option value="C">Prezzo calcolato</option>
								<option value="F">Prezzo fisso</option>
							</select>
						</div>
						<div class="col-6">
							<div class="input-group">
								<input class="form-control text-end" name="total" id="input-total"
									placeholder="Totale preventivo"
									data-bind="value: pricing.data.total">
								<span class="input-group-text">
									<i class="fas fa-euro-sign"></i>
								</span>
							</div>

						</div>
					</div>
					<div class="d-flex justify-content-end gap-2">
						<div class="py-2 text-end d-flex align-items-center gap-2">
							<div class="status" id="quotation-totals-item-loading"></div>
							#button(bind="click:update", variant="default", label="Aggiorna", size="sm", icon="sync-alt")#
						</div>
					</div>
				</div>

				<!--- 
					quotation princing
				--->
				<div id="quotation-totals-general-content" data-bind="visible: isGeneral">
					<div class="row mt-3 mb-2">
						<div class="col-8">Totale merce</div>
						<div class="col-4">
							<input class="form-control" name="shippingCost" 
								placeholder="%" data-bind="value: pricing.data.goodsTotal">
						</div>
					</div>
					<div class="row mt-3 mb-2 align-items-center d-flex">
						<div class="col-4">Sconti</div>
						<div class="col-4">
							<input class="form-control" name="discount1" 
								placeholder="%" data-bind="value: pricing.data.discount1">
						</div>
						<div class="col-4">
							<input class="form-control" name="discount2" 
								placeholder="%" data-bind="value: pricing.data.discount2">
						</div>
					</div>
					<div class="row mt-3 mb-2">
						<div class="col-8">Spese di trasporto</div>
						<div class="col-4">
							<input class="form-control" name="shippingCost" 
								placeholder="%" data-bind="value: pricing.data.shippingMethod.cost">
						</div>
					</div>
					<div class="d-flex justify-content-end gap-2">
						<div class="py-2 text-end d-flex align-items-center gap-2">
							<div class="status" id="quotation-totals-item-loading"></div>
							#button(bind="click:update", variant="default", label="Aggiorna", size="sm", icon="sync-alt")#
						</div>
					</div>
				</div>			

			</div>
		</div>
	</div>
</cfoutput>