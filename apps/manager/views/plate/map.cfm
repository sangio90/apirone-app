<cfscript>
	// Data from backend
	plates = [
		{
			"uuid" = createUUID(),
			"img" = "../../../../assets/main/img/plate1.png",
			"totalQuantity" = 1,
			"availableQuantity" = 1,
			"marker" = {
				"img" = "../../../../assets/main/img/red_pin.png",
				"model" = {
					"width" = 32,
					"height" = 32,
				},
			},
		},
		{
			"uuid" = createUUID(),
			"img" = "../../../../assets/main/img/plate2.png",
			"totalQuantity" = 10,
			"availableQuantity" = 10,
			"marker" = {
				"img" = "../../../../assets/main/img/green_pin.png",
				"model" = {
					"width" = 32,
					"height" = 32,
				},
			},
		},
		{
			"uuid" = createUUID(),
			"img" = "../../../../assets/main/img/plate3.png",
			"totalQuantity" = 100,
			"availableQuantity" = 100,
			"marker" = {
				"img" = "../../../../assets/main/img/blue_pin.png",
				"model" = {
					"width" = 32,
					"height" = 32,
				},
			},
		},
	];
	platesMap = {
		"img" = "../../../../assets/main/img/planimetria.jpg",
		"width" = 856, // in px
		"height" = 582, // in px
	};
</cfscript>

<cfoutput>
	<!--- TODO: se lo metto in jsFiles.json.cfm non funziona... --->
	<script src="/assets/main/js/vendor/markerjs3/umd/markerjs3.js"></script>
	<div id="plates-map-root">
		<div>
			<div class="header-toolbar">
				<div>
					<button
						type="button"
						data-bind="click: onClickRemoveMarker, enabled: isEnabledRemoveMarker">
						<i class="fas fa-trash"></i>
					</button>
				</div>

				<div style="display: flex; align-items: center;">
					<div>
						<input
							data-role="dropdownlist"
							data-value-field="uuid"
							data-template="tmplPlate"
							data-value-template="tmplPlate"
							data-bind="source: plates,
										value: selectedPlate,
										events: {
											select: onSelectPlate
										}"
							style="width: 100px;"
						/>
					</div>

					<div style="margin-left: 10px; width: 60px; display: flex; align-items: center;">
						<img
							data-bind="attr: { src: getSelectedPlateMarkerImg }"
							style="width: 30px; height: 30px;">

						<span
							style="margin-left: 5px;">
							x
						</span>

						<span
							style="margin-left: auto;"
							data-bind="text: selectedPlateMarkersQuantity">
						</span>
					</div>

					<button
						style="margin-left: 10px;"
						type="button"
						data-bind="click: onClickAddMarker,
									enabled: isEnabledAddMarker">
						Aggiungi
					</button>
				</div>

				<div>
					<button
						type="button"
						data-bind="click: onClickExport">
						<i class="fas fa-save"></i>
					</button>

					<button
						type="button"
						data-bind="click: onClickImport">
						Import
					</button>
				</div>
			</div>

			<!--- Dynamically populated container --->
			<div class="plates-map-body"></div>

			<div class="footer-toolbar">
				<button
					type="button"
					data-bind="click: onClickUndo, enabled: isEnabledUndo">
					<i class="fas fa-undo"></i>
				</button>

				<button
					type="button"
					data-bind="click: onClickRedo, enabled: isEnabledUndo">
					<i class="fas fa-redo"></i>
				</button>

				<button
					style="margin-left: auto;"
					type="button"
					data-bind="click: onClickZoomOut">
					<i class="fas fa-search-minus"></i>
				</button>

				<button
					type="button"
					data-bind="click: onClickZoomReset">
					<i class="fas fa-compress"></i>
				</button>

				<button
					type="button"
					data-bind="click: onClickZoomIn">
					<i class="fas fa-search-plus"></i>
				</button>
			</div>
		</div>
	</div>

	<script id="tmplPlate" type="text/template">
		<div>
			<img
				src="##= img##"
				style="height: 18px;">
		</div>
	</script>

	<script>
		pageData = {
			plates: #serializeJSON(plates)#,
			platesMap: #serializeJSON(platesMap)#,
		};
	</script>
</cfoutput>
