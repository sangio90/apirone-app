<cfprocessingdirective pageEncoding='UTF-8'>

<nmscript type="text/template" id="price-row-tmpl">
	<div style="padding: 2px 5px; text-align: right; cursor: pointer">
		<span data-bind="text: type.name"></span>:
		<strong data-bind="text: amount"></strong>
		<span data-bind="text: method.simbol"></span>
	</div>
</nmscript>
