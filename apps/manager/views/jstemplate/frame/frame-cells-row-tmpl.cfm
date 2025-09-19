<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="frame-cells-row-tmpl">
		<tr> <!---  non posso usare mvvm su <tr> ---->
			## for(var i=0; i < data.length; i++) { ##
				<td>
					<input type="text" maxlength="1" class="form-control"
						style="width: 40px; text-align: center;"
						value="##= data[i].value ##"
						data-row="##= data[i].rowIndex ##"
						data-col="##= data[i].colIndex ##"
						onchange="AP.frame.modal.editCell(##= data[i].rowIndex ##, ##= data[i].colIndex ##, this.value)">
				</td>
			## } ##
		</tr>
    </nmscript>

	#template( view="jstemplate/frame/frame-cells-col-tmpl" )#

</cfoutput>