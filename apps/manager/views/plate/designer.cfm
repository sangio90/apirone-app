<cfscript>
	GRID_CELL_DIMENSIONS = { // in px
		"WIDTH" = 45,
		"HEIGHT" = 180,
		"PROHIBITED_HEIGHT" = 104,
	};
	// Data from backend
	// LEGEND:
	// "A - Z" - Module Id (PK in DataBase)
	// "_" - empty free space
	// "0" - prohibited space
	PLATE_GRID = [
		["_", "A", "A", "A", "A", "_", "A2", "A2", "A2", "A2", "B", "B", "_", "_", "_", "_",],
		// ["0", "0", "0", "0", "0", "0",],
		// ["_", "C", "C", "_", "I", "I",],

		// ["A", "A", "A", "A", "B", "B"],
		// ["A", "A", "A", "A", "B", "B"],
		// ["0", "0", "0", "0", "0", "0"],
		// ["_", "C", "C", "_", "I", "I"],
		// ["_", "C", "C", "_", "I", "I"],

		// ["A", "A", "A", "A", "_", "_"],
		// ["A", "A", "A", "A", "_", "_"],
		// ["0", "0", "0", "0", "_", "_"],
		// ["_", "_", "_", "_", "B", "B"],
		// ["_", "_", "_", "_", "B", "B"],

		 // Special 2
		// ["0", "0", "B", "B",],
		// ["0", "0", "B", "B",],
		// ["0", "0", "0", "0",],
		// ["B2", "B2", "0", "0",],
		// ["B2", "B2", "0", "0",],
		// ["0", "0", "0", "0",],
		// ["A", "A", "A", "A",],
		// ["A", "A", "A", "A",],
	];

	PLATE_ELEMENTS = {
		A = {
			"id" = "A",
			"imgSrc" = "/assets/main/img/foto_frutto_schuko.png",
			"x1" = 1,
			"x2" = 4,
			"y1" = 0,
			"y2" = 0,
			"gaps" = {
				"x" = 0,
				"y" = 0,
			},
		},
		A2 = {
			"id" = "A2",
			"imgSrc" = "/assets/main/img/foto_frutto_schuko.png",
			"x1" = 6,
			"x2" = 9,
			"y1" = 0,
			"y2" = 0,
			"gaps" = {
				"x" = 0,
				"y" = 0,
			},
		},
		B = {
			"id" = "B",
			"imgSrc" = "/assets/main/img/foto_frutto_bipasso.png",
			"x1" = 10,
			"x2" = 11,
			"y1" = 0,
			"y2" = 0,
			"gaps" = {
				"x" = 0,
				"y" = 0,
			},
		},
		// C = {
		// 	"id" = "C",
		// 	"imgSrc" = "/assets/main/img/foto_frutto_cat6.png",
		// 	"x1" = 4,
		// 	"x2" = 5,
		// 	"y1" = 0,
		// 	"y2" = 0,
		// 	"gaps" = {
		// 		"x" = 0,
		// 		"y" = 0,
		// 	},
		// },
		// I = {
		// 	"imgSrc" = "/assets/main/img/foto_frutto_interruttore.png",
		// 	"x1" = 2,
		// 	"x2" = 3,
		// 	"y1" = 0,
		// 	"y2" = 0,
		// 	"gaps" = {
		// 		"x" = 0,
		// 		"y" = 0,
		// 	},
		// },
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

		<style>
			##plate-layers {
				width: #ArrayLen(PLATE_GRID[1]) * GRID_CELL_DIMENSIONS.WIDTH#px;
				height: #ArrayLen(PLATE_GRID) * GRID_CELL_DIMENSIONS.HEIGHT#px;
			}
		</style>

		<div class="plate-designer">
			<div class="plate-background horizontal-orientation" style="background-image: url('/assets/main/img/508.jpg');">
				<div
					id="plate-layers">
					<div
						id="plate-grid"
						style="grid-template-rows: #GRID_CELL_DIMENSIONS.HEIGHT#px #GRID_CELL_DIMENSIONS.PROHIBITED_HEIGHT#px #GRID_CELL_DIMENSIONS.HEIGHT#px; grid-template-columns: repeat(6, #GRID_CELL_DIMENSIONS.WIDTH#px);"
						>
						<cfloop from="1" to="#arrayLen(PLATE_GRID)#" index="y">
							<cfloop from="1" to="#arrayLen(PLATE_GRID[y])#" index="x">
								<cfscript>
									isProhibitedCell = PLATE_GRID[y][x] == "0";
								</cfscript>
								<div
									class="grid-column p#x# #isProhibitedCell ? 'prohibited' : ''#"
									style="grid-row: #y# / #y + 1#; grid-column: #x# / #x + 1#;"
									>
									<cfif NOT isProhibitedCell>
										<span class="position-label" style="font-size: 8px;">
											(#x#, #y#)
										</span>
									</cfif>
								</div>
							</cfloop>
						</cfloop>
					</div>

					<div
						id="plate-items"
						>
						<cfloop collection="#PLATE_ELEMENTS#" item="elementKey">
							<cfscript>
								element = PLATE_ELEMENTS[elementKey];

								left = GRID_CELL_DIMENSIONS.WIDTH * element.x1;
								top = GRID_CELL_DIMENSIONS.HEIGHT * element.y1 + (GRID_CELL_DIMENSIONS.PROHIBITED_HEIGHT * element.gaps.y);

								width = GRID_CELL_DIMENSIONS.WIDTH * (element.x2 - element.x1 + 1);
								height = GRID_CELL_DIMENSIONS.HEIGHT * (element.y2 - element.y1 + 1);
							</cfscript>

							<div
								id="#elementKey#"
								class="draggable-plate-item"
								style="left: #left#px; top: #top#px; width: #width#px; height: #height#px;"
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
	</div>

	<script>
		pageData = {};
		pageData.GRID_CELL_DIMENSIONS = #serializeJSON(GRID_CELL_DIMENSIONS)#;
		pageData.PLATE_GRID = #serializeJSON(PLATE_GRID)#;
		pageData.PLATE_ELEMENTS = #serializeJSON(PLATE_ELEMENTS)#;
	</script>
</cfoutput>
