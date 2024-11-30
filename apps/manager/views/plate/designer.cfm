<cfscript>
	GRID_CELL_DIMENSIONS = {
		"WIDTH" = 25, // in px
		"HEIGHT" = 45, // in px
	};
	// Data from backend
	// LEGEND:
	// "A - Z" - Module Id (PK in DataBase)
	// "_" - empty free space
	// "0" - prohibited space
	PLATE_GRID = [
		["A", "A", "A", "A", "B", "B"],
		["A", "A", "A", "A", "B", "B"],
		["_", "_", "_", "_", "_", "_"],
		["_", "_", "_", "_", "_", "_"],
	];

	PLATE_ELEMENTS = {
		A = {
			"imgSrc" = "/assets/main/img/foto_frutto_schuko.png",
			"x1" = 0,
			"y1" = 0,
			"x2" = 3,
			"y2" = 1,
		},
		B = {
			"imgSrc" = "/assets/main/img/foto_frutto_bipasso.png",
			"x1" = 4,
			"y1" = 0,
			"x2" = 5,
			"y2" = 1,
		},
	};
</cfscript>

<cfoutput>
	<div id="plate-designer-root">
		<div>
			<select name="fruits">
				<option value="schuko">
					Schuko
				</option>
				<option value="bipasso">
					Bipasso
				</option>
				<option value="usb">
					USB
				</option>
			</select>

			<button type="button">
				Aggiungi
			</button>
		</div>

		<div class="plate-designer">
			<div class="plate-background" style="background-image: url('/assets/main/img/foto_placca.png');">
				<div
					id="plate-grid"
					style="grid-auto-rows: #GRID_CELL_DIMENSIONS.HEIGHT#px; grid-auto-columns: #GRID_CELL_DIMENSIONS.WIDTH#px;"
					>
					<cfloop from="1" to="#arrayLen(PLATE_GRID)#" index="y">
						<cfloop from="1" to="#arrayLen(PLATE_GRID[y])#" index="x">
							<div
								class="grid-column p#x#"
								style="grid-row: #y# / #y + 1#; grid-column: #x# / #x + 1#;"
								>
								<span class="position-label" style="font-size: 8px;">
									(#x#, #y#)
								</span>
							</div>
						</cfloop>
					</cfloop>

					<cfloop collection="#PLATE_ELEMENTS#" item="elementKey">
						<cfscript>
							element = PLATE_ELEMENTS[elementKey];
						</cfscript>

						<div
							id="#elementKey#"
							class="draggable-plate-item"
							style="left: #GRID_CELL_DIMENSIONS.WIDTH * element.x1#px; top: #GRID_CELL_DIMENSIONS.HEIGHT * element.y1#px; width: #GRID_CELL_DIMENSIONS.WIDTH * (element.x2 - element.x1 + 1)#px; height: #GRID_CELL_DIMENSIONS.HEIGHT * (element.y2 - element.y1 + 1)#px;"
							>
							<img
								src="#element.imgSrc#"
								style="width: 100%; height: 100%; object-fit: fill;"
								>
						</div>
					</cfloop>
				</div>
			</div>
		</div>
	</div>

	<script>
		pageData = {};
		pageData.GRID_CELL_DIMENSIONS = #serializeJSON(GRID_CELL_DIMENSIONS)#;
		pageData.PLATE_GRID = #serializeJSON(PLATE_GRID)#;
		pageData.PLATE_ELEMENTS = #serializeJSON(PLATE_ELEMENTS)#;
	</script>
</cfoutput>
