<cfscript>
	// Data from backend
	GRID_CELL_DIMENSIONS = { // in px
		"_" = { // FREE
			"WIDTH" = 45,
			"HEIGHT" = 180,
			"ORIENTATION" = "H", // "V" - VERTICAL, "H" - HORIZONTAL. PS: CELL ORIENTATION IS INDIPENDENT FROM PLATE'S ORIENTATION
		},
		"0" = { // PROHIBITED
			"WIDTH" = 52,
			"HEIGHT" = 105,
			"ORIENTATION" = "H", // "V" - VERTICAL, "H" - HORIZONTAL
		},
	};
</cfscript>

<cfoutput>
	<div id="plate-designer-root">
		<div style="grid-column: 1 / 1; grid-row: 1 / 3; display: flex; flex-direction: column; width: 100%; align-items: center;">
			<button
				type="button"
				data-bind="click: onClickGenerali">
				<div>
					<i class="fas fa-info-circle"></i>
				</div>
				Generali
			</button>

			<label>Lista placche</label>

			<input
				data-role="dropdownlist"
				data-value-field="UUID"
				data-text-field="CODE"
				data-bind="source: plates,
						   value: selectedPlate"
				style="width: 100px"/>

			<button
				type="button"
				data-bind="click: onClickConfigura">
				<div>
					<i class="fas fa-cogs"></i>
				</div>
				Configura
			</button>

			<label>Lista frutti</label>

			<input
				data-role="dropdownlist"
				data-value-field="value"
				data-text-field="name"
				data-bind="source: fruits,
						   events: {
						       select: onSelectFruit
						   }"
				style="width: 100px"/>

			<button
				type="button"
				data-bind="click: onClickImmagine">
				<div>
					<i class="far fa-image"></i>
				</div>
				Immagine
			</button>
		</div>

		<div style="grid-column: 2 / 3; grid-row: 1 / 2; display: flex; width: 100%; align-items: center; justify-content: flex-end;">
			<input type="text" placeholder="Cerca frutto">
			<button
				type="button"
				data-bind="click: onClickCercaFrutto">
				🔍
			</button>
		</div>

		<!--- Dynamically populated container --->
		<div class="plate-designer">
			<div style="width: 1200px; height: 500px; display: flex; align-items: center; justify-content: center;">
				<h1 style="opacity: 0.5;">Definire le impostazioni generali per iniziare</h1>
			</div>
		</div>
	</div>

	<script>
		pageData = {};
		pageData.GRID_CELL_DIMENSIONS = #serializeJSON(GRID_CELL_DIMENSIONS)#;
	</script>
</cfoutput>
