<cfprocessingdirective pageEncoding='UTF-8'>

<nmscript type="text/template" id="price-form-list-row-tmpl">

	<div class="mb-3 row">
		<label class="col-sm-3 col-form-label text-end">
			<spa data-bind="text: type.name"></span>
			<spa data-bind="text: id"></span>
		</label>
		<div class="col-sm-9">

			<div class="row g-0">

				<div class="col-6 me-2">

					<select required
						name="methodId_#=id#"
						class="form-control"
						data-bind="source: methods, value: method }" 
						data-value-field="id"
						data-text-field="name">
					</select>

				</div>

				<div class="col-4 me-1">
					<input type="text" required class="form-control text-end" 
						name="amount_#=id#"
						maxlength="8"
						data-bind="value: amount">
				</div>

				<div class="col-1 mt-2">
					<span data-bind="text: method.simbol"></span>
				</div>

			</div>
			
		</div>
	</div>

</nmscript>
