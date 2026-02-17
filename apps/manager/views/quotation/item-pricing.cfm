<cfoutput>
	<div class="h-100">

		<div class="row">

			<div class="col-6">
				<div class="mb-1">Speciale:</div>
				<div>
					<input class="form-check-input" type="checkbox"
						name="special" 
						data-bind="value: detailForm.data.quotationItem.special">
				</div>
			</div>

			<div class="col-6 mb-2">

				<div class="mb-1">Stato:</div>
				<div>
					<select name="status" class="form-control form-control-sm" id="input-price-status"
						data-bind="source: detailForm.itemStatuses, value: detailForm.data.quotationItem.status"
						data-value-field="id"
						data-text-field="name"
						>
					</select>
				</div>
			</div>

			<div class="col-12">
				<div class="row mb-2">
					<div class="col-4 mt-2">Posizione:</div>
					<div class="col-8">
						<input class="form-control form-control-sm" name="position" 
							id="#args.id#-position"
							placeholder="Posizione" data-bind="value: detailForm.data.quotationItem.position.code">
					</div>
				</div>
			</div>

			<div class="col-12 mb-2">
				<textarea class="form-control" name="note" placeholder="Note" rows="4"
					data-bind="value: detailForm.data.quotationItem.note"></textarea>
			</div>

		</div>

		<div>
			#view(view="quotation/item-total-pricing", args=args)#
		</div>
		
	</div>
</cfoutput>