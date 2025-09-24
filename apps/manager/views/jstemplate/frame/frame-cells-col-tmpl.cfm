<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="frame-cells-col-tmpl">
		<div class="frame-grid-cell">
			<div class="frame-grid-cell-header">
				
				<div class="frame-grid-cell-header-label">
					<span data-bind="text: row"></span>/<span data-bind="text: col"></span>
				</div>

				<div class="frame-grid-cell-header-buttons">
					## if( col === 0 ) { ##

						#iconButton(icon="plus", 
							title="Aggiungi una riga sotto", class="btn-primary", size="sm",
							bind="click:addRowAfter"
						)#

						#iconButton(icon="minus", 
							title="Cancella riga", class="btn-danger", size="sm",
							bind="click:deleteRow"
						)#

					## } ##

					## if( row === 0 ) { ##

						#iconButton(icon="plus", 
							title="Aggiungi una colonna dopo", class="btn-primary", size="sm",
							bind="click:addCol"
						)#

						#iconButton(icon="minus", 
							title="Canella riga", class="btn-danger", size="sm",
							bind="click:deleteCol"
						)#

					## } ##

				</div>
			</div>

			<div class="frame-grid-cell-content">

				<select id="typeId" class="form-control" name="typeId"
					required
					data-bind="source: types, value: detailForm.data.orientation" 
					data-value-field="id"
					data-text-field="name"
					>
				</select>

				<!---
				<input type="text" maxlength="1" class="form-control"
					style="width: 40px; text-align: center;"
					value="##= value ##"
					data-row="##= row ##"
					data-col="##= col ##"
					data-bind="events: { change: updateCell }">
				---->
			</div>

		</div>
    </nmscript>
</cfoutput>
