<cfscript>
	// Data from backend
	GRID_CELL_DIMENSIONS = { // in px
		"_" = { // FREE
			"WIDTH" = 45,
			"HEIGHT" = 180,
		},
		"0" = { // PROHIBITED
			"WIDTH" = 52,
			"HEIGHT" = 105,
		},
	};
</cfscript>

<cfoutput>
	<div id="plate-designer-root">
		<div style="grid-column: 1 / 1; grid-row: 1 / 3; display: flex; flex-direction: column; width: 100%; align-items: stretch; z-index: 1;">
			<button
				type="button"
				data-bind="click: onClickGenerali">
				<div>
					<i class="fas fa-info-circle"></i>
				</div>
				Generali
			</button>


			<label>Lista placche</label>

			<div>
				<input
					data-role="dropdownlist"
					data-value-field="UUID"
					data-text-field="CODE"
					data-bind="source: plates,
							   value: selectedPlate"
				/>
			</div>

			<button
				type="button"
				data-bind="click: onClickConfigura">
				<div>
					<i class="fas fa-cogs"></i>
				</div>
				Configura
			</button>

			<button
				type="button"
				data-bind="click: onClickListaFrutti">
				<div>
					<i class="fas fa-list"></i>
				</div>
				Lista frutti
			</button>

			<button
				type="button"
				data-bind="click: onClickImmagine">
				<div>
					<i class="far fa-image"></i>
				</div>
				Immagine
			</button>
		</div>

		<div style="grid-column: 2 / 3; grid-row: 1 / 2; display: flex; width: 100%; align-items: center; justify-content: flex-end; z-index: 1;">
			<input
				data-role="dropdownlist"
				data-value-field="uuid"
				data-text-field="name"
				data-filter="contains"
				data-bind="source: fruits,
						   events: {
						       select: onSelectFruit
						   }"
				data-option-label="🔍 Cerca frutto..."
				style="width: 200px"/>
		</div>

		<!--- Dynamically populated container --->
		<div class="plate-designer">
			<div style="width: 1200px; height: 500px; display: flex; align-items: center; justify-content: center;">
				<h1 style="opacity: 0.5;">Definire le impostazioni generali per iniziare</h1>
			</div>
		</div>
	</div>

	<script>
		pageData = {
			GRID_CELL_DIMENSIONS: #serializeJSON(GRID_CELL_DIMENSIONS)#,
		};
	</script>
</cfoutput>
