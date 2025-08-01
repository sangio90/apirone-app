AP.lineCategory = AP.lineCategory || {};

AP.lineCategory.fields = {
    listRoot: $("#line-category-list-root"),
    searchForm: $("#line-category-search-form"),
};

$(document).ready(function () {
    if (AP.lineCategory.fields.listRoot.length) {
        AP.lineCategory.list.init();
    }
});

AP.lineCategory.list = (function () {
    var pub = {};
    var fields = AP.lineCategory.fields;

    var dataSources = {
        items: NM.kendo.dataSource({ url: "/manager/ajax/lines/categories/" + AP.page.categoryId }),
    };

    var fields = AP.lineCategory.fields;

    var viewModel = kendo.observable({
        rows: dataSources.items,

        search: function (event) {
            var thisForm = fields.searchForm;

            var params = thisForm.serializeJSON();
            var filters = [];

            var dataSource = viewModel.get("rows");

            var filterDataSource = new kendo.data.DataSource({
                data: dataSource.data().toJSON(),
            });

            if (params.str.length) {
                filters.push({
                    field: "name",
                    operator: "contains",
                    value: params.str,
                });
            }

            filterDataSource.filter(filters);

            viewModel.set("rows", filterDataSource);

            return false;
        },

        change: function (event) {
            var select = $(event.currentTarget);
            var categoryId = select.val();
            var category = select.find("option:selected").data("name");
            var title = "Linee per < " + category + " >";

            // change url and title
            window.history.pushState({}, "", categoryId);
            document.title = title;

            fields.listRoot.find("h2").text(title);

            viewModel.set("rows", NM.kendo.dataSource({ url: "/manager/ajax/lines/categories/" + categoryId }));

            return false;
        },

        products: function (event) {
            console.log("fields.listRoot", fields.listRoot);

            var id = event.data.id;
            var categoryId = fields.listRoot.find("[name=categoryId]").val();

            window.open("/manager/lines/" + id + "/categories/" + categoryId + "/products", "_blank").focus();

            return false;
        },

        attributes: function (event) {
            /*
                note: redirect in controller to first product
            */

            var id = event.data.id;
            window.open("/manager/lines/" + id + "/attributes", "_blank").focus();

            return false;
        },
    });

    pub.init = function () {
        console.log("listCategory:init");

        kendo.bind(AP.lineCategory.fields.listRoot, viewModel);
    };

    return pub;
})();
