<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="frame-cells-col-tmpl">
		<div class="frame-grid-cell" data-bind="css: { frame-cell-command: isCommand, frame-cell-empty: isEmpty, frame-cell-available: isAvailable, frame-cell-unvailable: isUnvailable, frame-cell-first: isFirstLeftCell }">
			<div class="frame-grid-cell-header">
				<div class="frame-grid-cell-header-label">
					<span data-bind="text: data.row"></span>/<span data-bind="text: data.col"></span>
				</div>

				<div class="frame-grid-cell-header-buttons">

					<div data-bind="visible: showRowCommands">
						<span>Riga:</span>

						#iconButton(icon="plus", 
							title="Aggiungi una riga sotto", class="btn-primary", size="xs",
							bind="click:addRow"
						)#

						#iconButton(icon="minus", 
							title="Cancella riga", class="btn-danger", size="xs",
							bind="click:deleteRow"
						)#

					</div>

					<div data-bind="visible: showColCommands">

						<span>Colonna:</span>

						#iconButton(icon="plus", 
							title="Aggiungi una colonna dopo", class="btn-primary", size="xs",
							bind="click:addCol"
						)#

						#iconButton(icon="minus", 
							title="Cancella colonna", class="btn-danger", size="xs",
							bind="click:deleteCol"
						)#

					</div>

					<div data-bind="visible: showCellEdit">

						#iconButton(icon="cog", 
							title="Edita cella", class="btn-primary", size="xs",
							bind="click:editCell"
						)#

					</div>

				</div>
			</div>

			<div class="frame-grid-cell-content" data-bind="visible: showContent">
				Type: <span data-bind="text: data.type.id"></span>
				Larghezza: <span data-bind="text: data.width"></span>
				Altezza: <span data-bind="text: data.height"></span>
			</div>

		</div>

    </nmscript>
	
</cfoutput>
