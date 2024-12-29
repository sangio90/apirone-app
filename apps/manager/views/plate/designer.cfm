<cfscript>
	GRID_CELL_DIMENSIONS = { // in px
		"WIDTH" = 45,
		"HEIGHT" = 180,
		"PROHIBITED_HEIGHT" = 104,
	};
	// Data from backend
	PLATE = {
		"WIDTH": 1200, // in px
		"HEIGHT": 500, // in px
		"ORIENTATION": "V", // "V" - VERTICAL, "H" - HORIZONTAL
		"GRID" = [
			// LEGEND:
			// "_" - empty free space
			// "0" - prohibited space
			["_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_",],
			// ["_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "0", "0", "_", "_",],
		]
	};

	FRUITS = {
		// A = {
		// 	"width": GRID_CELL_DIMENSIONS.WIDTH * 4,
		// 	"height": GRID_CELL_DIMENSIONS.HEIGHT * 1,
		// 	"uuid": "A",
		// 	"code": "schuko",
		// 	"name": "SCHK 2P + 1T",
		// 	"img": "/assets/main/img/foto_frutto_schuko.png",
		// 	"row": 0,
		// 	"column": 0,
		// },
		A2 = {
			"width": GRID_CELL_DIMENSIONS.WIDTH * 4,
			"height": GRID_CELL_DIMENSIONS.HEIGHT * 1,
			"uuid": "A2",
			"code": "schuko",
			"name": "SCHK 2P + 1T",
			"img": "/assets/main/img/foto_frutto_schuko.png",
			"row": 0,
			"column": 6,
		},
		B = {
			"width": GRID_CELL_DIMENSIONS.WIDTH * 2,
			"height": GRID_CELL_DIMENSIONS.HEIGHT * 1,
			"uuid": "B",
			"code": "bipasso",
			"name": "BIPAS.",
			"img": "/assets/main/img/foto_frutto_bipasso.png",
			"row": 0,
			"column": 10,
		},
		C = {
			"width": GRID_CELL_DIMENSIONS.WIDTH * 2,
			"height": GRID_CELL_DIMENSIONS.HEIGHT * 1,
			"uuid": "C",
			"code": "cat6",
			"name": "CAT 6",
			"img": "/assets/main/img/foto_frutto_cat6.png",
			"row": 0,
			"column": 12,
		},
		I = {
			"width": GRID_CELL_DIMENSIONS.WIDTH * 2,
			"height": GRID_CELL_DIMENSIONS.HEIGHT * 1,
			"uuid": "I",
			"code": "switch",
			"name": "INT. Sottile",
			"img": "/assets/main/img/foto_frutto_interruttore.png",
			"row": 0,
			"column": 14,
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

		<!--- Dynamically populated container --->
		<div class="plate-designer"></div>
	</div>

	<script>
		pageData = {};
		pageData.GRID_CELL_DIMENSIONS = #serializeJSON(GRID_CELL_DIMENSIONS)#;
		pageData.PLATE = #serializeJSON(PLATE)#;
		pageData.FRUITS = #serializeJSON(FRUITS)#;
	</script>
</cfoutput>
