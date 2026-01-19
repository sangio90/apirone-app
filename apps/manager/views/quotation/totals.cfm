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