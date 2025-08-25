<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
	<nmscript type="text/template" id="metadata-detail-row-tmpl">
		<div class="mb-3 row">
			<label class="col-sm-2 col-form-label text-end" data-bind="text: type.name" ></label>
			<div class="col-sm-10">
				<input type="text" required class="form-control col-sm-4" 
					name="form-metadata-##:uid##" id="form-metadata-##:uid##"
					data-rule-##:validationRule##="true"
					data-msg-##:validationRule##="##:validationMsg##"
					data-bind="value: value">
					
				<div id="form-metadata-##:uid##-error">
				</div>
			</div>
		</div>
	</nmscript>
</cfoutput>
