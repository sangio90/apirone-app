component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="code" type="String";
	property name="orientation" type="com.apirone.core.model.bean.Orientation";
	property name="orientationAvailable" type="com.apirone.core.model.bean.Orientation[]";
	property name="cellOrientation" type="com.apirone.core.model.bean.Orientation";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="cells" type="com.apirone.core.model.bean.FrameCell[]";
	property name="blocks" type="com.apirone.core.model.bean.FrameBlock[]";
	property name="marginRightMm" type="Numeric" default=0;
	property name="marginBottomMm" type="Numeric" default=0;

	public Frame function init(){
		return this;
	}

	public Array function getGrid(){

		/*
			{

				"cells":[
					{
						"height":0,
						"col":1,
						"width":0,
						"id":212,
						"type":{
						"name":"Disponibile",
						"id":"AVAIL"
						},
						"row":1,
						"orientation":{
						"name":"Orizzontale",
						"id":"HOR"
						}
					},
					{
						"height":0,
						"col":2,
						"width":0,
						"id":213,
						"type":{
						"name":"Disponibile",
						"id":"AVAIL"
						},
						"row":1,
						"orientation":{
						"name":"Orizzontale",
						"id":"HOR"
						}
					},
					{
						"height":0,
						"col":3,
						"width":0,
						"id":214,
						"type":{
						"name":"Disponibile",
						"id":"AVAIL"
						},
						"row":1,
						"orientation":{
						"name":"Orizzontale",
						"id":"HOR"
						}
					},
					{
						"height":0,
						"col":4,
						"width":0,
						"id":215,
						"type":{
						"name":"Disponibile",
						"id":"AVAIL"
						},
						"row":1,
						"orientation":{
						"name":"Orizzontale",
						"id":"HOR"
						}
					},
					{
						"height":0,
						"col":5,
						"width":0,
						"id":216,
						"type":{
						"name":"Vuoto",
						"id":"EMPTY"
						},
						"row":1,
						"orientation":{
						"name":"Orizzontale",
						"id":"HOR"
						}
					},
					{
						"height":0,
						"col":6,
						"width":0,
						"id":217,
						"type":{
						"name":"Disponibile",
						"id":"AVAIL"
						},
						"row":1,
						"orientation":{
						"name":"Orizzontale",
						"id":"HOR"
						}
					},
					{
						"height":0,
						"col":7,
						"width":0,
						"id":218,
						"type":{
						"name":"Disponibile",
						"id":"AVAIL"
						},
						"row":1,
						"orientation":{
						"name":"Orizzontale",
						"id":"HOR"
						}
					},
					{
						"height":0,
						"col":8,
						"width":0,
						"id":219,
						"type":{
						"name":"Disponibile",
						"id":"AVAIL"
						},
						"row":1,
						"orientation":{
						"name":"Orizzontale",
						"id":"HOR"
						}
					},
					{
						"height":0,
						"col":9,
						"width":0,
						"id":220,
						"type":{
						"name":"Disponibile",
						"id":"AVAIL"
						},
						"row":1,
						"orientation":{
						"name":"Orizzontale e verticale",
						"id":"HAV"
						}
					}
				],
			}
			}		
   		*/

		/*
		GRID: [
			// LEGEND:
			// "_" - empty free space
			// "0" - prohibited space
			[ "0", "0", "_", "_" ],
			[ "_", "_", "0", "0" ],
			[ "_", "_", "_", "_" ],
		],		
		*/

		// "_" - empty free space
		// "0" - prohibited space
		var grid = [];
		var rowMap = {};
		
		// raggruppa le celle per row
		for( var cell in getCells() ){
			var rowNum = cell.getRow();
			if( ! StructKeyExists( rowMap, rowNum ) ){
				rowMap[rowNum] = [];
			}
			
			var cellValue = "_";

			if( cell.getType().getId() == "EMPTY" ) {
				cellValue = "0";
			}
			
			rowMap[rowNum].append(cellValue);
		}
		
		// costruisci l'array ordinato per row
		var rowKeys = structKeyArray(rowMap);
		
		arraySort(rowKeys, "numeric");
		
		for( var rowNum in rowKeys ){
			grid.append( rowMap[rowNum] );
		}

		// Se cellOrientation è VERTICAL, trasponi la matrice
		if( !isNull(getCellOrientation()) && getCellOrientation().getId() == "VER" ) {
			grid = transposeGrid(grid);
		}

		return grid;
	}

	private Array function transposeGrid( required Array grid ){
		var transposed = [];
		
		if( arrayLen(grid) == 0 ) {
			return transposed;
		}
		
		var numRows = arrayLen(grid);
		var numCols = arrayLen(grid[1]);
		
		// Crea la matrice trasposta: colonne diventano righe
		for( var col = 1; col <= numCols; col++ ){
			var newRow = [];
			for( var row = 1; row <= numRows; row++ ){
				newRow.append( grid[row][col] );
			}
			transposed.append( newRow );
		}
		
		return transposed;
	}

}
