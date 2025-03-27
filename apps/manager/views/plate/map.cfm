<cfscript>
</cfscript>

<cfoutput>
	<div id="plate-map-root">
		<!--- Dynamically populated container --->
		<div class="plate-map">
			<button
				type="button"
				data-bind="click: onClickAddArrow">
				Add Arrow
			</button>

			<button
				type="button"
				data-bind="click: onClickSave">
				Save
			</button>
		</div>
	</div>

	<script>
		pageData = {
		};
	</script>
</cfoutput>
