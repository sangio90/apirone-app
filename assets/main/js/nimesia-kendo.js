var NM = {};
NM.kendo = NM.kendo || {};

NM.kendo.dataSource = function (config = {}) {

    var dataSource = new kendo.data.DataSource({
        transport: {
          // The remote endpoint which will receive the request parameters and return the response containing the data.
          read: {
            url: "http://apirone.local:7110/manager/ajax/lines/categories",
          }
        },
        schema: {
            data: "data", 
            pageSize: "count",
            total: "total"
        },
        serverPaging: true,
        pageSize: 10, // The number of items per page.
        page: 3 // Change the page property to see a different set of items. The endpoint contains 77 items in total. This means that there are eight pages (eight pages multiplied by 10 records each).
      });

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