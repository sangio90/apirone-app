<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8"/>
    <title></title>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://kendo.cdn.telerik.com/2024.3.1015/js/kendo.all.min.js"></script>
    <script src="/assets/main/js/nimesia-kendo.js"></script>

</head>
<body>
  
<div id="root">

    <h4 data-bind="text: title"></h4>

    <table border="1">
        <tbody data-bind="source: rows" data-template="row-tmpl">
        </tbody>
    </table>
    
</div>

<script type="text/x-kendo-template" id="row-tmpl">
    <tr>
        <td nowrap>
            <span data-bind="text: status.name"></span>
        </td>
    </tr>
</script>

<script>

    function getDS() {

        var dataSource = NM.kendo.dataSource({ 
            url: "/manager/ajax/combinations/c3d8a2f9-09cc-4814-8971-0398819ecd7a/items?start=1"
        });

        return dataSource;

    }

    var viewModel = kendo.observable({
        title: "Questo è il titolo",
        rows: undefined
    });

    viewModel.set("rows", getDS() );

    kendo.bind( $("#root"), viewModel );

    var d = viewModel.get("rows");


    console.log("d.total", d.total())

</script>

</body>
</html>