<cfscript>
</cfscript>

<cfoutput>
	<div id="plate-map-root">
		<!--- Dynamically populated container --->
		<div class="plate-map">
			<button
				type="button"
				data-bind="click: onClickAddPin">
				Add Pin
			</button>

			<button
				type="button"
				data-bind="click: onClickZoomIn">
				Zoom-in
			</button>

			<button
				type="button"
				data-bind="click: onClickZoomReset">
				Zoom-reset
			</button>

			<button
				type="button"
				data-bind="click: onClickZoomOut">
				Zoom-out
			</button>
			<button
				type="button"
				data-bind="click: onClickExport">
				Export
			</button>
			<button
				type="button"
				data-bind="click: onClickImport">
				Import
			</button>
		</div>
	</div>

	<script>
		pageData = {
		};
	</script>
</cfoutput>
