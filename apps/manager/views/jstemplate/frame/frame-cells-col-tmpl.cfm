<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="frame-cells-col-tmpl">
		<div class="frame-grid-cell">
			<div><span data-bind="text: row"></span>/<span data-bind="text: col"></span></div>
			
			<input type="text" maxlength="1" class="form-control"
				style="width: 40px; text-align: center;"
				value="##= value ##"
				data-row="##= row ##"
				data-col="##= col ##"
				data-bind="events: { change: updateCell }">

			## if(col === 0) { ##

				<button type="button" class="btn btn-sm btn-success" 
					data-bind="click: addRowAfter">
					+ riga
				</button>

				<button type="button" class="btn btn-sm btn-danger"
    				data-bind="click: deleteRow">
					- riga
				</button>

			## } ##

			## if(row === 0) { ##

				<button type="button" class="btn btn-sm btn-success" 
					data-bind="click: addColAfter">
					+ colonna
				</button>
				
				<button type="button" class="btn btn-sm btn-danger" 
					data-bind="click: deleteCol">
					- colonna
				</button>

			## } ##
		</div>
    </nmscript>
</cfoutput>
