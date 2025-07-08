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

    console.log(" dataSource.data() ", dataSource.length );
    dataSource.fetch();
    
    console.log(" dataSource.data() ", dataSource.data() );

    var viewModel = kendo.observable({
        title: "Questo è il titolo",
        rows: dataSource,
        total: dataSource.data().length
    });

    kendo.bind( $("#root"), viewModel );

    var ds = viewModel.get("rows");

    ds.add( { name: "Katia" } );

    //ds.sync()

    var ds = viewModel.get("rows");

    
    console.log("ds1", dataSource );
    console.log("ds:kendo", new kendo.data.DataSource( [ 
            { name: "Roberto" },
            { name: "Alessandra" },
            { name: "Emanuela" },
        ] )  );



    for( var item of dataSource.data() ) {
        console.log("item", item);
    }

    for (var i = 0; i < dataSource.data().length; i++) {
        console.log("===item", dataSource.data()[i]);
    }

    console.log(" dataSource.data() ", ds.data().length );


</script>

</body>
</html>