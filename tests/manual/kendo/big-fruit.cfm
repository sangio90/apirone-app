<!DOCTYPE html>
<html>

<head>
	<title>Kendo - big fruit</title>
	<link href="https://kendo.cdn.telerik.com/themes/12.2.3/default/default-ocean-blue.css" rel="stylesheet" />
	<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
	<script src="https://kendo.cdn.telerik.com/2025.4.1111/js/kendo.all.min.js"></script>
</head>

<script id="product-tmpl" type="text/x-kendo-template">
	<div>
		<span>#= status.id #</span>
		<span>#= attributeValue.rawValue.name #</span>
		<span>#= attributeValue.rawValue.id #</span>
		<span>#= attributeValue.id #</span>
	</div>
</script>

<script id="product-tmpl-mvvm" type="text/x-kendo-template">
	<div>
		<span data-bind="text: status.id"></span>
		<span data-bind="text: attributeValue.rawValue.name"></span>
		<span data-bind="text: attributeValue.rawValue.id"></span>
		<span data-bind="text: attributeValue.id"></span>
	</div>
</script>

<body>
	<div id="demo">
		<div class="k-d-flex">

			<div data-bind="source: products" data-template="product-tmpl">
			</div>

			<div data-bind="source: products" data-template="product-tmpl-mvvm">
			</div>

		</div>

		<script>
			var viewModel = kendo.observable({
				products: new kendo.data.DataSource({
					transport: {
						read: {
							url: "/tests/assets/big-fruit.json",
						},
					},
					schema: {
						data: function( xhr ) {
							return xhr.data;
						}
					}
				}),
			});
			kendo.bind($("#demo"), viewModel);

			var renderStart = new Date().getTime();
			window.onload=function() { 
				var elapsed = new Date().getTime()-renderStart;
				// send the info to the server 
				//alert('Rendered in ' + elapsed + 'ms'); 
			} 			
		</script>
	</div>
</body>

</html>