<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
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

</cfoutput>