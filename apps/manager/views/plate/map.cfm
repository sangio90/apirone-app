<cfscript>
</cfscript>

<cfoutput>
	<div id="plate-map-root">
		<button
			type="button"
			data-bind="click: onClickAddPin">
			Add Pin
		</button>

		<button
			type="button"
			data-bind="click: onClickRemovePin, enabled: isEnabledRemovePin">
			<i class="fas fa-trash"></i>
		</button>

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
			type="button"
			data-bind="click: onClickZoomIn">
			<i class="fas fa-search-plus"></i>
		</button>

		<button
			type="button"
			data-bind="click: onClickZoomReset">
			<i class="fas fa-compress"></i>
		</button>

		<button
			type="button"
			data-bind="click: onClickZoomOut">
			<i class="fas fa-search-minus"></i>
		</button>

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

		<!--- Dynamically populated container --->
		<div class="plate-map">
		</div>
	</div>

	<script>
		pageData = {
		};
	</script>
</cfoutput>
