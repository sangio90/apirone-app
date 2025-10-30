<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
	<nmscript type="text/template" id="metadata-detail-row-tmpl">
		<div class="mb-3 row">

			<label class="col-sm-2 col-form-label text-end le-14">
				<span data-bind="text: type.name"></span>
				<br>
				<span class="small-code" data-bind="text: type.measurementUnit.id"></span>
			</label>

			<div class="col-sm-10">

				##if (type.dataType.id == 'BOOLEAN') {## 

					<input type="checkbox" class="form-check-input" 
						name="metadata_##:type.code##" id="metadata_##:type.code##"
						data-bind="checked: value">

				##} else {##

					<input type="text" class="form-control" 
						name="metadata_##:type.code##" id="metadata_##:type.code##"
						data-bind="value: value">

				##}##
			</div>

		</div>
	</nmscript>
</cfoutput>
