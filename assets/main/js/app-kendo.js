ZB.kendo = ZB.kendo || {};

ZB.kendo.dataSource = function( config = {} ) {

    console.log("config", config)
    console.log("config?.data", config?.data)

    var defaults = {
        data: config.data ? config.data : [],
        pageSize: config?.count,
        serverPaging: config?.serverPaging,
        serverSorting: config?.serverSorting,
        change: function() {
            /* setto un indice numerico per riga */
            $.each(this.data(), function(index, item) {
                item.set( "index", index+1 );
            });
        }
    };

    if ( config.url != undefined ) {
        
        defaults[ "transport" ] = { "read": config.url };
        defaults[ "schema" ] = { "data": "data", pageSize: "count" };

        if ( config.model ) {
            defaults[ "schema" ][ "model" ] = config.model
        }

    }

	var settings = $.extend( true, defaults, config );

    var dataSource = new kendo.data.DataSource( settings );

    return dataSource;

};


/*
    remove scrollbar in grid
*/
ZB.kendo.toggleScrollbar = function( event ) {
    var gridWrapper = event.sender.wrapper;
    var gridDataTable = event.sender.table;
    var gridDataArea = gridDataTable.closest(".k-grid-content");

    //gridWrapper.toggleClass("no-scrollbar", gridDataTable[0].offsetHeight < gridDataArea[0].offsetHeight);
    gridWrapper.addClass("no-scrollbar");
}
