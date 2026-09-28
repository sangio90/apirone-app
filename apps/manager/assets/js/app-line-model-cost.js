AP.namespace( "lineModelCost" );

Object.assign( AP.lineModelCost.fields, {
    listRoot: $( "#line-model-cost-list-root" ),
} );

$( document ).ready( function() {
    if ( AP.lineModelCost.fields.listRoot.length ) {
        AP.lineModelCost.list.init();
    }
} );

AP.lineModelCost.list = ( function() {
    var pub = {};

    var URL = "/manager/ajax/lines_model_costs";

    // combinazioni categoria/linea/modello esistenti a catalogo (catalog_bundles)
    var combinations = AP.page.combinations || [];
    var linesById = {};
    var modelsById = {};
    ( AP.page.lines || [] ).forEach( function( line ) { linesById[ line.id ] = line; } );
    ( AP.page.models || [] ).forEach( function( model ) { modelsById[ model.id ] = model; } );

    var byName = function( a, b ) { return ( a.name || "" ).localeCompare( b.name || "" ); };

    // linee presenti a catalogo per la categoria
    var linesFor = function( categoryId ) {
        var seen = {};
        return combinations
            .filter( function( c ) { return categoryId && c.categoryId == categoryId; } )
            .filter( function( c ) { return !seen[ c.lineId ] && ( seen[ c.lineId ] = true ); } )
            .map( function( c ) { return linesById[ c.lineId ]; } )
            .filter( Boolean )
            .sort( byName );
    };

    // modelli presenti a catalogo per la coppia categoria/linea
    var modelsFor = function( categoryId, lineId ) {
        var seen = {};
        return combinations
            .filter( function( c ) { return categoryId && lineId && c.categoryId == categoryId && c.lineId == lineId; } )
            .filter( function( c ) { return !seen[ c.modelId ] && ( seen[ c.modelId ] = true ); } )
            .map( function( c ) { return modelsById[ c.modelId ]; } )
            .filter( Boolean )
            .sort( byName );
    };

    var emptyForm = function() {
        return { categoryId: "", lineId: "", modelId: "", cost: "" };
    };

    var save = function( data, onSuccess ) {
        AP.loading.show();
        NM.util.ajax( {
            method: "POST",
            url: URL,
            data: JSON.stringify( data ),
            callback: {
                done: function( xhr ) {
                    AP.loading.hide();
                    var message = xhr.data && xhr.data.message;
                    if ( xhr.status == "ERROR" ) {
                        AP.widget.notify( "error", message || "Non è possibile salvare questo costo fisso." );
                        return;
                    }
                    AP.widget.notify( "success", message || "Salvato." );
                    onSuccess && onSuccess();
                }
            }
        } );
    };

    var viewModel = kendo.observable( {
        rows: NM.kendo.dataSource( { url: URL } ),
        categories: AP.page.categories,

        search: emptyForm(),
        searchLines: [],
        searchModels: [],

        form: emptyForm(),
        formLines: [],
        formModels: [],

        onSearchCategoryChange: function() {
            this.set( "searchLines", linesFor( this.get( "search.categoryId" ) ) );
            this.set( "search.lineId", "" );
            this.onSearchLineChange();
        },

        onSearchLineChange: function() {
            this.set( "searchModels", modelsFor( this.get( "search.categoryId" ), this.get( "search.lineId" ) ) );
            this.set( "search.modelId", "" );
        },

        onFormCategoryChange: function() {
            this.set( "formLines", linesFor( this.get( "form.categoryId" ) ) );
            this.set( "form.lineId", "" );
            this.onFormLineChange();
        },

        onFormLineChange: function() {
            this.set( "formModels", modelsFor( this.get( "form.categoryId" ), this.get( "form.lineId" ) ) );
            this.set( "form.modelId", "" );
        },

        doSearch: function() {
            var params = {};
            [ "categoryId", "lineId", "modelId" ].forEach( function( key ) {
                var value = viewModel.get( "search." + key );
                if ( value ) {
                    params[ key ] = value;
                }
            } );

            viewModel.rows.read( params );

            return false;
        },

        create: function() {
            var form = this.get( "form" ).toJSON();

            if ( !form.categoryId || !form.lineId || !form.modelId || !String( form.cost ).length ) {
                AP.widget.notify( "error", "Compilare tutti i campi." );
                return false;
            }

            save( {
                id: null,
                categoryId: form.categoryId,
                lineId: form.lineId,
                modelId: form.modelId,
                cost: form.cost
            }, function() {
                bootstrap.Modal.getInstance( document.getElementById( "lineModelCostAddModal" ) ).hide();
                viewModel.set( "form", emptyForm() );
                viewModel.set( "formLines", [] );
                viewModel.set( "formModels", [] );
                viewModel.rows.read();
            } );

            return false;
        },

        update: function( event ) {
            var row = event.data;

            if ( row.cost === "" || row.cost === null || isNaN( row.cost ) ) {
                AP.widget.notify( "error", "Inserire un costo valido." );
                return false;
            }

            save( {
                id: row.id,
                categoryId: row.category.id,
                lineId: row.line.id,
                modelId: row.model.id,
                cost: row.cost
            } );

            return false;
        },

        remove: function( event ) {
            AP.loading.show();
            NM.util.ajax( {
                method: "DELETE",
                url: URL,
                data: JSON.stringify( { id: event.data.id } ),
                callback: {
                    done: function( xhr ) {
                        AP.loading.hide();
                        var message = xhr.data && xhr.data.message;
                        if ( xhr.status == "ERROR" ) {
                            AP.widget.notify( "error", message || "Non è possibile cancellare questo costo fisso." );
                            return;
                        }
                        AP.widget.notify( "success", message || "Cancellato." );
                        viewModel.rows.read();
                    }
                }
            } );

            return false;
        },
    } );

    pub.init = function() {
        kendo.bind( AP.lineModelCost.fields.listRoot, viewModel );
    };

    return pub;
} () );
