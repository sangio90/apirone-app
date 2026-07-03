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

    // placeholder in testa alle liste: senza, Kendo seleziona il primo elemento reale
    function withPlaceholder( items, textField ) {
        var placeholder = { id: "" };
        placeholder[ textField || "name" ] = "-- seleziona";
        return [ placeholder ].concat( items || [] );
    }

    var defaultDetailForm = {
        data: {
            id: "",
            code: "",
            positionCount: "",
            category: { id: "" },
            line: { id: "" },
            model: { id: "" },
            selectedFinishes: [],
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
        categories: withPlaceholder( AP.page.categories ),
        lines: withPlaceholder( AP.page.lines ),
        models: withPlaceholder( AP.page.models, "code" ),
        finishes: AP.page.finishes || [], // multiselect: niente placeholder

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
            if ( !category || !category.id ) {
                this.get('lines').data(allLines);
            } else {
                // line.categories può essere null per le linee senza categorie associate
                const categoryLines = allLines.filter(function(line) {
                    return ( line.categories || [] ).filter(cat => cat.id == category.id).length > 0
                })
                this.get('lines').data(categoryLines);
            }
            this.set('line', { "id": "", "name": ""})
            this.set('model', { "id": "", "name": ""})
        },

        loadModels: function() {
            this.get('models').data([]);
            let allModels = this.get("allModels");
            const category = this.get('category')
            if (!category || !category.id) {
                this.get('models').data(allModels);
                this.set('model', { "id": "", "name": ""})
                return;
            }
            const categoryModels = allModels.filter(function(model) {
                return ( model.categories || [] ).filter(cat => cat.id == category.id).length > 0
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
            viewModel.set( "detailForm", JSON.parse( JSON.stringify( defaultDetailForm ) ) );
        },

        new: function( event ) {
            this.resetForm();

            NM.util.openModal( AP.fields.product.detailRoot );

            return false;
        },

        save: function( event ) {
            var thisForm = AP.fields.product.detailForm;
            var status = thisForm.find( ".status" );

            if ( !thisForm.valid() ) {
                return false;
            }

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/products",
                data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                callback: {
                    done: function( xhr ) {
                        status.html( "" );

                        AP.widget.notify( "success", xhr.data.message.text );

                        setTimeout( () => AP.fields.product.detailRoot.modal( "hide" ), 500 );

                        viewModel.rows.read();
                    },
                },
            } );

            return false;
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
        viewModel.loadLines();
    };

    return pub;
}() );
