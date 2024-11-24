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


		<div class="plate-designer">
			<div class="plate-background" style="background-image: url('/assets/main/img/foto_placca.png');">
				<div id="config_grid" class="dim_placca_6">
					<div id="plate-grid">
						<div class="grid-column p1">
							<span class="position-label">Pos 1</span>
						</div>
						<div class="grid-column p2">
							<span class="position-label">Pos 2</span>
						</div>
						<div class="grid-column p3">
							<span class="position-label">Pos 3</span>
						</div>
						<div class="grid-column p4">
							<span class="position-label">Pos 4</span>
						</div>
						<div class="grid-column p5">
							<span class="position-label">Pos 5</span>
						</div>
						<div class="grid-column p6">
							<span class="position-label">Pos 6</span>
						</div>

						<div id="draggable-plate-item" style="cursor: move;">
							<img style="width: 100%; height: 100%; object-fit: fill;" id="foto_frutto_shuko" src="/assets/main/img/foto_frutto.png">
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</cfoutput>
