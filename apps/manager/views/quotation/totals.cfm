<cfoutput>
	<div id="quotation-totals" class="container py-3 quotation-totals-box">
		<div>
			<div class="d-flex hand" data-bind="click: collapseTotals">
				<div class="justify-content-start" style="width: 95%" id="qt-totals-title">
					<h3 data-bind="text: common.title"></h3>
				</div>
				<div style="font-size: 1.5em;"
					id="qt-item-totals-symbol" data-bind="text:common.symbol"></div>
			</div>

			<div class="quotation-totals-content" id="quotation-totals-content" data-bind="invisible:common.isCollapsed">
			
				<!--- 
					item princing
				--->
				<div id="quotation-totals-item-content" data-bind="visible: isItem">
					<div class="row mb-2">
						<div class="col-4">
							<div class="mb-1">Stato:</div>
							<div>
								<select name="status" class="form-control form-control-sm" id="input-price-status"
									data-bind="value: item.status">
									<option value="ACT" SELECTED>Attivo</option>
									<option value="BLK">Bloccato</option>
								</select>
							</div>
						</div>
						<div class="col-4">
							<div class="mb-1">Posizione:</div>
							<div>
								<input class="form-control form-control-sm" name="position" 
									placeholder="Posizione" data-bind="value: pricing.data.position.code">
							</div>
						</div>
						<div class="col-4">
							<div class="mb-1">Speciale:</div>
							<div>
								<input class="form-check-input" type="checkbox"
									name="special" 
									data-bind="value: item.special">
							</div>
						</div>
					</div>

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
							<select name="priceMethod" class="form-control" id="input-price-method"
								data-bind="value: pricing.data.method.id, events: { change: changeMethod }">
								<option value="C">Prezzo calcolato</option>
								<option value="F">Prezzo fisso</option>
							</select>
						</div>
						<div class="col-6">
							<div class="input-group">
								<input class="form-control text-end" name="total" id="input-item-total"
									placeholder="Totale preventivo"
									data-format="0.00"
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
							#button(bind="click:updateItem", variant="default", label="Aggiorna", size="sm", icon="sync-alt")#
						</div>
					</div>
				</div>

				<!--- 
					total princing
				--->
				<div id="quotation-totals-general-content" data-bind="visible: isGeneral">
					<div class="d-flex align-items-center justify-content-between" >
						<div>
							<div>Placche:</div>
							<span data-bind="text: pricing.counters.plates"></span>
						</div>
						<div>
							<div>Segnaletiche:</div>
							<span data-bind="text: pricing.counters.signages"></span>
						</div>
						<div>
							<div>Accessori:</div>
							<span data-bind="text: pricing.counters.accessories"></span>
						</div>
					</div>
					<div class="row mt-3 mb-2">
						<div class="col-8">Totale merce</div>
						<div class="col-4 text-end">
							<span data-bind="text: pricing.data.totalGoods" data-format="0.00"></span> &euro;
						</div>
					</div>
					<div class="row mt-3 mb-2 align-items-center d-flex">
						<div class="col-4">Sconti</div>
						<div class="col-4">
							<input class="form-control text-end" name="discount1"
								placeholder="%" data-bind="value: pricing.data.discount1">
						</div>
						<div class="col-4">
							<input class="form-control text-end" name="discount2" 
								placeholder="%" data-bind="value: pricing.data.discount2">
						</div>
					</div>
					<div class="row mt-3 mb-2">
						<div class="col-8">Spese di trasporto</div>
						<div class="col-4">
							<input class="form-control text-end" name="shippingCost" 
								placeholder="%" data-bind="value: pricing.data.shippingCost">
						</div>
					</div>
					<div class="row mt-3 mb-2">
						<div class="col-8">Sconto incondizionato</div>
						<div class="col-4">
							<input class="form-control text-end" name="flatDiscount" 
								placeholder="%" data-bind="value: pricing.data.flatDiscount">
						</div>
					</div>
					<div class="row mt-3 mb-2">
						<div class="col-8">Iva <span data-bind="text: pricing.data.vatPercentage"></span>%</div>
						<div class="col-4 text-end">
							<span data-bind="text: pricing.data.vatAmount" data-format="0.00"></span> &euro;
						</div>
					</div>
					<div class="row mt-3 mb-2">
						<div class="col-6"><b>TOTALE</b></div>
						<div class="col-6 text-end fs-16" >
							<b><span data-bind="text: pricing.data.total" data-format="0.00"></span> &euro;</b>
						</div>
					</div>
					<div class="d-flex justify-content-end gap-2">
						<div class="py-2 text-end d-flex align-items-center gap-2">
							<div class="status" id="quotation-totals-general-loading"></div>
							#button(bind="click:updateTotals", variant="default", label="Salva", size="sm", icon="fa-save")#
						</div>
					</div>
				</div>			

			</div>
		</div>
	</div>
</cfoutput>