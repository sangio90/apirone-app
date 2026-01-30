<cfprocessingdirective pageEncoding="UTF-8">

<nmscript type="text/template" id="price-row-tmpl">
	<div>
		<span data-bind="text: type.name"></span>
		<i>(<span data-bind="text: type.id"></span>)</i> :
		<strong data-bind="text: amount"></strong>
		<span data-bind="text: method.simbol"></span>
	</div>
</nmscript>
