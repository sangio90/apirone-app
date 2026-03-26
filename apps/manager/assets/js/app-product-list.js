AP.product = AP.product || {};
AP.fields.product = AP.fields.product || {};

AP.fields.product = {
    listRoot: $( "#product-list-root" ),
    detailRoot: $( "#product-detail-modal" ),
    attributesRoot: $( "#product-detail-root" ),
    detailForm: $( "#product-detail-form" ),
    searchListForm: $( "#product-grid-search-form" ),
};

$( document ).ready( function(){

    if ( AP.fields.product.listRoot.length ) {
        AP.product.list.init();
    }

} );

AP.product.list = ( function() {

    var pub = {};
    var fields = AP.fields.product;
    var detailApp = AP.product.detail;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/products" } )
    };

    var defaultDetailForm = {
        data: {
            id: "",
            code: "",
            positionCount: "",
            category: {
                id: 167 // TODO: add dynamic value according to current category
            },
            nameItem: {
                id: "",
                name: "",
                lang: {
                    id: "IT"
                }
            },
            status: {
                id: "ACT"
            }
        },
        statuses: AP.page.statuses,

        title: "Carica prodotto"
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,
        detailForm: defaultDetailForm,
        categories: AP.page.categories,
        category: {
            "id": "",
            "name": ""
        },
        allLines: AP.page.lines,
        lines: new kendo.data.DataSource(),
        line: {
            "id": "",
            "name": ""
        },
        allModels: AP.page.models,
        models: new kendo.data.DataSource(),
        model: {
            "id": "",
            "name": ""
        },
        // methods: AP.page.methods,

        loadLines: function() {
            this.get('lines').data([]);
            let allLines = this.get("allLines");
            const category = this.get('category')
            const categoryLines = allLines.filter(function(line) {
                return line.categories.filter(cat => cat.id == category.id).length > 0
            })
            this.get('lines').data(categoryLines);
            this.set('line', { "id": "", "name": ""})
            this.set('model', { "id": "", "name": ""})
        },

        loadModels: function() {
            this.get('models').data([]);
            let allModels = this.get("allModels");
            const category = this.get('category')
            const categoryModels = allModels.filter(function(model) {
                return model.categories.filter(cat => cat.id == category.id).length > 0
            })
            this.get('models').data(categoryModels);
            this.set('model', { "id": "", "name": ""})
        },

        editPrices: function( event ) {

            var onSave = function() {
                viewModel.rows.read();
            };


            var item = {
                type: "product",
                id: event.data.id,
                line: event.data.line,
                model: event.data.model,
                finish: event.data.finish,
            };

            console.log( "editPrices", item );

            AP.price.modal.open( item, onSave );

        },

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
        },

        attributes: function( event ) {
            var id = event.data.id;
            window.open( "/manager/products/" + id + "/detail", "_blank" ).focus();

            return false;
        },

        search: function( event ) {

            var thisForm = AP.fields.product.searchListForm;

            console.log( "searchListForm", thisForm );

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;

        },

        print: function( event ) {

            var target = $( event.currentTarget );
            var report = target.data( "report" );

            var qs = $( "#product-grid-search-form" ).serialize();

            var id = event.data.id;
            window.open( "/manager/products/print/" + report + "?" + qs, "_blank" ).focus();

            return false;
        },

    } );

    pub.init = function() {

        kendo.bind( AP.fields.product.listRoot, viewModel );

    };

    return pub;
}() );
