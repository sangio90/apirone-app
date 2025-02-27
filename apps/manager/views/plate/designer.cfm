<cfscript>
	// Data from backend
	PLATE = { // horizontal
		"UUID" = "",
		"CODE" = "508",
		"IMG" = "/assets/main/img/508.jpg",
		"WIDTH" = 1200, // in px
		"HEIGHT" = 500, // in px
		"ORIENTATION" = "H", // "V" - VERTICAL, "H" - HORIZONTAL
		"GRID" = [
			// LEGEND:
			// "_" - empty free space
			// "0" - prohibited space
			["_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_", "_",],
			// ["_", "_", "_", "_",],
			// ["0", "0", "0", "0",],
			// ["_", "_", "_", "_",],
		]
	};

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

	FRUITS = {
		A = {
			"row" = 0,
			"column" = 6,
			"width" = GRID_CELL_DIMENSIONS["_"].WIDTH * 4,
			"height" = GRID_CELL_DIMENSIONS["_"].HEIGHT * 1,
			"orientation" = "H",
			"uuid" = "A",
			"code" = "schuko",
			"name" = "SCHK 2P + 1T",
			"img" = "/assets/main/img/foto_frutto_schuko.png",
		},
		// A2 = {
		// 	"width" = GRID_CELL_DIMENSIONS["_"].WIDTH * 4,
		// 	"height" = GRID_CELL_DIMENSIONS["_"].HEIGHT * 1,
		// 	"orientation" = "V",
		// 	"uuid" = "A2",
		// 	"code" = "schuko",
		// 	"name" = "SCHK 2P + 1T",
		// 	"img" = "/assets/main/img/foto_frutto_schuko.png",
		// 	"row" = 0,
		// 	"column" = 6,
		// },
		B = {
			"row" = 0,
			"column" = 0,
			"width" = GRID_CELL_DIMENSIONS["_"].WIDTH * 2,
			"height" = GRID_CELL_DIMENSIONS["_"].HEIGHT * 1,
			"orientation" = "H",
			"uuid" = "B",
			"code" = "bipasso",
			"name" = "BIPAS.",
			"img" = "/assets/main/img/foto_frutto_bipasso.png",
		},
		C = {
			"row" = 0,
			"column" = 2,
			"width" = GRID_CELL_DIMENSIONS["_"].WIDTH * 2,
			"height" = GRID_CELL_DIMENSIONS["_"].HEIGHT * 1,
			"orientation" = "H",
			"uuid" = "C",
			"code" = "cat6",
			"name" = "CAT 6",
			"img" = "/assets/main/img/foto_frutto_cat6.png",
		},
		// I = {
		// 	"width" = GRID_CELL_DIMENSIONS["_"].WIDTH * 2,
		// 	"height" = GRID_CELL_DIMENSIONS["_"].HEIGHT * 1,
		// 	"orientation" = "H",
		// 	"uuid" = "I",
		// 	"code" = "switch",
		// 	"name" = "INT. Sottile",
		// 	"img" = "/assets/main/img/foto_frutto_interruttore.png",
		// 	"row" = 0,
		// 	"column" = 10,
		// },
	};
</cfscript>

<cfoutput>
	<div id="plate-designer-root">
		<!--- <div>
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
		</div> --->

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
