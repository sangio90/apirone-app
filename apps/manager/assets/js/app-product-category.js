AP.productCategory = AP.productCategory || {};

AP.productCategory.fields = {
    listRoot: $("#product-category-list-root"),
    searchForm: $("#product-category-grid-search-form"),
    detailRoot: $("#product-category-detail-modal"),
    detailForm: $("#product-category-detail-form"),
};

$(document).ready(function () {
    if (AP.productCategory.fields.listRoot.length) {
        AP.productCategory.list.init();
    }
});

AP.productCategory.list = (function () {
    var pub = {};
    var fields = AP.productCategory.fields;

    var defaultDetailForm = {
        data: {
            id: "",
            code: "",
            mainText: {
                name: "",
                id: "",
                lang: {
                    id: "IT",
                },
            },
            status: {
                id: "ACT",
            },
            type: {
                id: "",
            },
            mode: {
                id: "COM",
            },
        },

        statuses: AP.page.statuses,
        types: AP.page.types,
        modes: AP.page.modes,

        title: "Carica categoria",
    };

    var dataSources = {
        items: NM.kendo.dataSource({ url: "/manager/ajax/product-categories" }),
    };

    var viewModel = kendo.observable({
        detailForm: defaultDetailForm,
        rows: dataSources.items,

        search: function (event) {
            var thisForm = fields.searchForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read(params);

            return false;
        },

        resetForm: function () {
            var detailForm = fields.detailForm;

            var validator = detailForm.validate();
            validator.resetForm();

            detailForm.find(".status").html("");

            viewModel.set("detailForm", defaultDetailForm);
        },

        save: function (event) {
            var detailForm = fields.detailForm;
            var status = detailForm.find(".status");

            status.html(
                "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>",
            );

            if (detailForm.valid()) {
                NM.util.ajax({
                    method: "POST",
                    url: "/manager/ajax/product-categories",
                    data: JSON.stringify(viewModel.get("detailForm.data")),
                    callback: {
                        done: function (xhr) {
                            if (xhr.status == "SUCCESS") {
                                viewModel.rows.read();

                                NM.util.autoHideMessage(
                                    status,
                                    "<span class='green'>Categoria salvata</span>",
                                );

                                setTimeout(
                                    () => $("#line-detail-modal").modal("hide"),
                                    1000,
                                );
                            }
                        },
                    },
                });
            }

            return false;
        },

        new: function () {
            viewModel.resetForm();

            NM.util.openModal(fields.detailRoot);
        },

        edit: function (event) {
            viewModel.resetForm();

            viewModel.set("detailForm.data", event.data);
            viewModel.set(
                "detailForm.title",
                "Modifica categoria <" + event.data.code + " >",
            );

            NM.util.openModal(fields.detailRoot);

            return false;
        },

        delete: function (event) {
            var checks = $("#product-category-grid").find(
                "[name=selected]:checked",
            );

            if (checks.length) {
                var values = [];

                checks.each(function () {
                    values.push($(this).val());
                });

                var ids = values.toString();

                NM.util.ajax({
                    method: "DELETE",
                    url: "/manager/ajax/product-categories",
                    data: ids,
                    callback: {
                        done: function (xhr) {
                            console.log(xhr);
                            if (xhr.data.payload.hasOwnProperty("errors")) {
                                AP.widget.notify(
                                    "error",
                                    "Non riesco a cancellare tutte le categorie",
                                );
                            } else {
                                AP.widget.notify(
                                    "success",
                                    "Cancellazione avvenuta con successo",
                                );
                            }

                            viewModel.rows.read();
                        },
                    },
                });
            } else {
                AP.widget.notify(
                    "warning",
                    "Devi selezionare almeno una catetoria",
                );
            }
        },
    });

    pub.init = function () {
        kendo.bind(fields.listRoot, viewModel);

        var detailForm = fields.detailForm;

        AP.page.types.unshift({
            id: "",
            name: "-- Seleziona una tipologia",
        });

        detailForm.validate({
            onfocusout: function (element) {
                $(element).valid();
            },
            rules: {
                typeId: {
                    required: true,
                },
                modeId: {
                    required: true,
                },
                code: {
                    required: true,
                    checkCode: true,
                    remote: {
                        url: "/manager/ajax/product-categories/code-exists",
                        data: {
                            id: function () {
                                return viewModel.get("detailForm.data.id");
                            },
                        },
                        dataFilter: function (xhr) {
                            var json = JSON.parse(xhr);
                            return json.data == false;
                        },
                    },
                },
            },
            messages: {
                typeId: {
                    required: "Tipo richiesto",
                },
                modeId: {
                    required: "Comportamento richiesto",
                },
                code: {
                    required: "Codice richiesto",
                    checkCode:
                        "Solo numeri, lettere, trattino o trattino basso",
                    remote: "Il codice esiste",
                },
            },
        });
    };

    return pub;
})();
