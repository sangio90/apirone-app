var NM = {};
NM.kendo = NM.kendo || {};

NM.kendo.dataSource = function (config = {}) {

    var dataSource = new kendo.data.DataSource({
        transport: {
          // The remote endpoint which will receive the request parameters and return the response containing the data.
          read: {
            url: "http://apirone.local:7110/manager/ajax/lines/categories",
          },

            parameterMap: function (data, type) {
                console.log("data.pageSize", data.pageSize);
                console.log("type", type);
                return {
                    $page: data.page
                }
          
            },

        },
        pageSize: 20,
        schema: {
            data: "data", 
            total: "total"
        },

      
        serverPaging: true
      });

      console.log("dataSource:total", dataSource.total())
      console.log("dataSource:pageSize", dataSource.pageSize())

      //dataSource.pageSize( dataSource.totalPages )

      return dataSource;

};

/*
NM.kendo.dataSource = function (config = {}) {

    var defaults = {
        data: config.data ? config.data : [],
        pageSize: config?.count,
        serverPaging: config?.serverPaging,
        serverSorting: config?.serverSorting,
        change: function () {
            $.each(this.data(), function (index, item) {
                item.set("index", index+1);
            });
        }
    };

    if (config.url != undefined) {

        defaults.transport = { "read": config.url };
        defaults.schema = { "data": "data", pageSize: "count" };

        if (config.model) {
            defaults.schema.model = config.model;
        }

    }

	var settings = $.extend(true, defaults, config);

    var dataSource = new kendo.data.DataSource(settings);

    return dataSource;

};
*/

/*
    remove scrollbar in grid
*/
NM.kendo.toggleScrollbar = function (event) {
    var gridWrapper = event.sender.wrapper;
    var gridDataTable = event.sender.table;
    var gridDataArea = gridDataTable.closest(".k-grid-content");

    gridWrapper.addClass("no-scrollbar");
};

NM.kendo.formatDate = function (date, type="normal") {
    // example date, from server: July, 13 2022 10:50:39 +0200, culture: en-US

    if (type == "normal") {
        var ret = kendo.toString(kendo.parseDate(date, "MMMM, dd yyyy HH:mm:ss", "en-US"), "dd/MM/yyyy HH:mm");
    }

    if (type == "short") {
        var ret = kendo.toString(kendo.parseDate(date, "MMMM, dd yyyy HH:mm:ss", "en-US"), "dd/MM");
    }

    return ret;
};