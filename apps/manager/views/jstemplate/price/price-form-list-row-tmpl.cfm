<cfprocessingdirective pageEncoding='UTF-8'>

<nmscript type="text/template" id="price-form-list-row-tmpl">

	<div class="mb-3 row">
		<label class="col-sm-3 col-form-label text-end">
			<spa data-bind="text: type.name"></span>
			<spa data-bind="text: id"></span>
		</label>
		<div class="col-sm-9">

			<div class="row">

				<div class="col-7">

					<select required
						name="methodId_#=id#"
						class="form-control"
						data-bind="source: methods, value: method.id" 
						data-value-field="id"
						data-text-field="name">
					</select>

				</div>

				<div class="col-5">
					<input type="text" required class="form-control col-sm-4" 
						name="amount_#=id#"
						maxlength="8"
						data-bind="value: amount">
				</div>

			</div>
			
		</div>
	</div>

</nmscript>
