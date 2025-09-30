<cfprocessingdirective pageEncoding='UTF-8'>

<nmscript type="text/template" id="price-row-tmpl">

	<div class="mb-3 row">
		<label class="col-sm-2 col-form-label text-end" data-bind="text:type.name"></label>
		<div class="col-sm-10 d-flex align-items-center">
			<select required
				class="form-control"
				data-bind="source: detailForm.types, value: detailForm.data.type.id" 
				data-value-field="id"
				data-text-field="name">
			</select>                                        
			<input type="text" required class="form-control col-sm-4" 
				name="code"
				maxlength="20"
				data-bind="value: detailForm.data.amount">
		</div>
	</div>

</nmscript>
