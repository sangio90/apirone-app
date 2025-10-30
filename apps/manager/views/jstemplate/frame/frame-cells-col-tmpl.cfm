<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="frame-cells-col-tmpl">
		<div class="frame-grid-cell" data-bind="css: { frame-cell-command: isCommand, frame-cell-empty: isEmpty, frame-cell-available: isAvailable, frame-cell-unvailable: isUnvailable, frame-cell-first: isFirstLeftCell }">
			<div class="frame-grid-cell-header">
				<div class="frame-grid-cell-header-label">
					<span data-bind="text: data.row"></span>/<span data-bind="text: data.col"></span>
				</div>

				<div class="frame-grid-cell-header-buttons">

					<div data-bind="visible: showRowCommands">

						#iconButton(icon="trash", 
							title="Cancella riga", class="btn-danger mb-2", size="xs",
							bind="click:deleteRow"
						)#

						<br>

						#iconButton(icon="plus", 
							title="Aggiungi una riga sotto", class="btn-primary", size="xs",
							bind="click:addRow"
						)#

					</div>

					<div data-bind="visible: showColCommands">

						#iconButton(icon="trash", 
							title="Cancella colonna", class="btn-danger", size="xs",
							bind="click:deleteCol"
						)#

						#iconButton(icon="plus", 
							title="Aggiungi una colonna dopo", class="btn-primary", size="xs",
							bind="click:addCol"
						)#

					</div>

					<div data-bind="visible: showCellEdit">

						#iconButton(icon="ellipsis-v", 
							title="Cambia orientamento", class="btn-default width-30", size="xs",
							bind="click:toggleOrientation",
							iconBind="css: { fa-ellipsis-v: isVertical, fa-ellipsis-h: isHorizontal, fa-grip-vertical: isHorizontalAndVertical }"
						)#

						#iconButton(icon="layer-group", 
							title="Cambia contenuto", class="btn-default", size="xs",
							bind="click:changeType"
						)#

						#iconButton(icon="cog", 
							title="Edita cella", class="btn-primary", size="xs",
							bind="click:editCell"
						)#

					</div>

				</div>
			</div>

			<div class="frame-grid-cell-content" data-bind="visible: showContent">
				<span data-bind="text: data.type.name"></span>,
				L: <span data-bind="text: data.width"></span> 
				H: <span data-bind="text: data.height"></span>
			</div>

		</div>

    </nmscript>
	
</cfoutput>
