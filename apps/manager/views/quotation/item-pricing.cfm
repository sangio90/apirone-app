<cfoutput>
	<div class="h-100">

		<div class="row">

			<div class="col-3">
				<div class="mb-1">Speciale:</div>
				<div>
					<input class="form-check-input" type="checkbox"
						name="special" 
						data-bind="checked: detailForm.data.quotationItem.special">
				</div>
			</div>
			<div class="col-5">
				<div id="imageCustomInput" data-bind="visible: detailForm.data.quotationItem.id">
					<div class="mb-1">Immagine Custom:</div>
					<div>
						<input class="form-check-input me-4" type="checkbox"
							name="customImage" 
							data-bind="checked: detailForm.data.quotationItem.customImage, events: { change: toggleCustomImage }"
						>
						<a type="button" class="btn btn-primary btn-sm"
							data-type="quotationItem"
							data-bind="click:openImagesList, visible: showCustomImage"
							style="font-size: 10px;"
						>
							Aggiungi <i class="fas fa-image"></i>
						</a>
					</div>
				</div>
			</div>

			<div class="col-4 mb-2">

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
			<div class="col-4 mt-2">Zona:</div>
			<div class="col-8">
				<select
					class="form-control my-2"
					name="zona"
					data-bind="source: zones, value: quotationZone, events: { change: changeZone }"
					data-value-field="id"
					data-text-field="name"
					id="zones-selector">
				</select>
			</div>
			<div class="col-4 mt-2">Sottozona:</div>
			<div class="col-8">
				<select
					class="form-control form-control my-2"
					name="sottozona"
					data-bind="source: subzones, value: quotationSubzone, enabled: isSubzoneEnabled"
					data-value-field="id"
					data-text-field="name"
					id="subzones-selector">
				</select>
			</div>
			<div class="col-12 mb-1" data-bind="visible: detailForm.data.quotationItem.id">
				<button type="button" class="btn btn-outline-secondary btn-sm" data-bind="click: openInPlant">
					<i class="fas fa-map-marker-alt"></i> Visualizza in pianta
				</button>
			</div>
			<div class="col-12">
				<div class="row mb-2">
					<div class="col-4 mt-2">Posizione:</div>
					<div class="col-8">
						<input class="form-control form-control-sm uppercase" name="position" 
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