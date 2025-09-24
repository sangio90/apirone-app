<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>

	#template( view="jstemplate/frame/frame-cells-col-tmpl" )#

    <nmscript type="text/x-kendo-template" id="frame-cells-row-tmpl">

		<div data-bind="source: cells" data-template="frame-cells-col-tmpl" class="frame-grid-row">
			
		</div>
		<!----
		<div class="frame-grid-row">
			## for(var j=0; j < data.length; j++) { ##
				<div class="frame-grid-cell">
					<div>##= data[j].row ##/##= data[j].col ##</div>
					
					<input type="text" maxlength="1" class="form-control"
						style="width: 40px; text-align: center;"
						value="##= data[j].value ##"
						data-row="##= data[j].row ##"
						data-col="##= data[j].col ##"
						onchange="AP.frame.modal.updateCell(##= data[j].row ##, ##= data[j].col ##, this.value)">

					## if(data[j].col === 0) { ##

						<button type="button" class="btn btn-sm btn-success" 
							onclick="AP.frame.modal.addRowAfter(##= data[j].row ##)">
							+ riga
						</button>

						<button type="button" class="btn btn-sm btn-danger" 
							onclick="AP.frame.modal.deleteRow(##= data[j].row ##)">
							- riga
						</button>

					## } ##

					## if(data[j].row === 0) { ##

						<button type="button" class="btn btn-sm btn-success" 
							onclick="AP.frame.modal.addColAfter(##= data[j].col ##)">
							+ colonna
						</button>
						
						<button type="button" class="btn btn-sm btn-danger" 
							onclick="AP.frame.modal.deleteCol(##= data[j].col ##)">
							- colonna
						</button>

					## } ##
				</div>
			## } ##
		</div>
		----->
    </nmscript>

	<!---

    <nmscript type="text/x-kendo-template" id="frame-cells-row-tmpl">
		<div data-bind="source: data" data-template="frame-cells-col-tmpl">
		</div>
    </nmscript>

	#template( view="jstemplate/frame/frame-cells-col-tmpl" )#
    <nmscript type="text/x-kendo-template" id="frame-cells-row-tmpl">
		<!---  non posso usare mvvm su <tr> ---->
		<tr> 
			## for(var i=0; i < data.length; i++) { ##
				<td>
					<input type="text" maxlength="1" class="form-control"
						style="width: 40px; text-align: center;"
						value="##= data[i].value ##"
						data-row="##= data[i].row ##"
						data-col="##= data[i].col ##"
						onchange="AP.frame.modal.updateCell(##= data[i].row ##, ##= data[i].col ##, this.value)">
				</td>
			## } ##
		</tr>
    </nmscript>
	---->
</cfoutput>