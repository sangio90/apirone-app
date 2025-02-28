var NM = {};
NM.kendo = NM.kendo || {};

NM.kendo.dataSource = function (config = {}) {

    var defaults = {
        data: config.data ? config.data : [],
        params: config.params ? config.params : {},
        pageSize: config.count ? config.count : 15,
        serverSorting: config?.serverSorting,

        change: function () {
            $.each(this.data(), function (index, item) {
                item.set("index", index+1);
            });
        }
    };

    defaults.schema = { "data": "data", total: "total" };

    if (config.url != undefined) {

        defaults.serverPaging = true;

        defaults.transport = {};
        defaults.transport.read = {};

        defaults.transport.read.url = config.url;

        defaults.transport.parameterMap = function (params, type ) {

            // merge
            Object.assign(params, config.params);

            params.count = params.pageSize;
            delete params.pageSize;
            delete params.skip;
            delete params.take;

            // add query string to pager ajax call
            defaults.transport.read.data = params;

            return params;
        };

        if( config.requestStart ) {
            defaults.requestStart = config.requestStart;
        }

        if( config.requestEnd ) {
            defaults.requestEnd = config.requestEnd;
        }

        if (config.model) {
            defaults.schema.model = config.model;
        }

        if ( config.model ) {
            defaults.schema.model = config.model;
        }

    }

    var dataSource = new kendo.data.DataSource( defaults );

    return dataSource;

};

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