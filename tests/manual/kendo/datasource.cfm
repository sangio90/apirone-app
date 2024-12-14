<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8"/>
    <title></title>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://kendo.cdn.telerik.com/2024.3.1015/js/kendo.all.min.js"></script>
</head>
<body>
  

<div id="root">

    <h4 data-bind="text: title"></h4>

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

    function getDS() {

        var dataSource = new kendo.data.DataSource( {
            transport: {
                read: {
                    url: "/manager/ajax/components",
                    data: { "ciccio": 1, "pasticcio": 1 }
                }
            },
            schema: {
                data: "data", 
                total: "total" 
            }
        });

        return dataSource;

    }

    function load() {

        console.log("load");

        var dataSource = getDS();

        console.log("viewModel", viewModel)

        viewModel.set( "rows", dataSource.read() );

    }

    var viewModel = kendo.observable({
        title: "Questo è il titolo",
        rows: getDS()
    });

    kendo.bind( $("#root"), viewModel );

    setTimeout(() => {
        //load()
    }, 500);

    //dataSource.read( { str: 1 } );
    
</script>

</body>
</html>