<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8"/>
    <title></title>

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://kendo.cdn.telerik.com/2024.3.1015/js/kendo.all.min.js"></script>
</head>
<body>
  
<div>

<script>

    console.log("init");
  	//var ds = new kendo.data.DataSource( { url: "http://www.apirone.local:7110/manager/ajax/components?page=1&count=15" } );
  	var ds = new kendo.data.DataSource( {
        transport: {
            read: "/manager/ajax/components?page=1&count=15"
        },
        schema: {
            data: "data", 
            total: "total" 
        }
    });

    ds.read( { str: 1 } );
    
    /*
    ds.fetch(function(){
        var currentView = ds.view();  
        currentView.forEach(function(el){
            console.log("el", el)
        });
    });
    */
  
</script>
</body>
</html>