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

    <h3 data-bind="text: title"></h3>
    
    <p data-bind="text: total"></p>

    <table border="1">
        <tbody data-bind="source: rows" data-template="tmpl">

        </tbody>
    </table>
    
</div>

<script type="text/x-kendo-template" id="tmpl">
    <tr>
        <td nowrap>
            <span data-bind="text: name"></span>
        </td>
    </tr>
</script>

<script>

    var dataSource = NM.kendo.dataSource({ 
        data: [ 
            { name: "Roberto" },
            { name: "Alessandra" },
            { name: "Emanuela" },
        ]
    });

    dataSource.fetch();

    var viewModel = kendo.observable({
        title: "Questo è il titolo",
        rows: dataSource,
        total: dataSource.total()
    });

    kendo.bind( $("#root"), viewModel );

</script>

</body>
</html>