<!DOCTYPE html>
<html>

<head>
	<title>Kendo - big fruit</title>
	<link href="https://kendo.cdn.telerik.com/themes/12.2.3/default/default-ocean-blue.css" rel="stylesheet" />
	<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
	<script src="/modules/assets/kendoui/js/kendo.all.min.js"></script>
</head>

<body>
	<div id="demo">
		<div class="k-d-flex">

			<cfinclude template="helpers.cfm">

			<cfoutput>
			#grid(
				id      = "product-items-grid",
				class   = "no-pager",
				columns = "[
					{ 'field':'Id', 'title':'ID', width: '70px' },
					{ 'field':'name', 'title':'Attributo' },
					{ 'field':'', 'title':'Prezzo', width: '180px'},
					{ 'field':'', 'title':'Aggiungi immagini', width: '55px'},
					{ 'field':'', 'title':'Aggiungi altri attributi', width: '55px'},
					{ 'field':'', 'title':'Aggiungi componenti all\'attributo', width: '55px'},
					{ 
						'field'           :'', 
						'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
						'width'           :'40px',
						'headerAttributes': { 'class': 'text-center' }
					}
				]",
				source: "products",
				rowTemplate = "product/product-item-row-tmpl"
			)#
			</cfoutput>

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
		</script>	
</body>

</html>