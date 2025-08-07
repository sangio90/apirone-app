AP.component = AP.component || {};

AP.component.fields = {
    rootList: $( "#component-list-modal" ),
};

$( document ).ready( function(){

    if ( AP.component.fields.rootList.length ) {

        AP.component.list.init();

    }

} );


AP.component.list = ( function() {

    var pub = {};
    var fields = AP.component.fields;

    var dataSources = {
        selected: new kendo.data.DataSource(
            {
                data: [],
                // calculates an id every time the ds is modified
                change: function( event ) {
                    var data = this.data();

                    for( var item of data ) {
                        item.code = createCode( item );
                    }

                }
            }
        )
    };

    var selectedExists = function( row ) {

        var code = createCode( row );

        var dataSource = viewModel.get( "selected" );

        for( var item of dataSource.data() ) {
            if ( item.code == code ) {
                return true;
            }
        }

        return false;

    };

    var getCurrentConfig = function() {

        var current = viewModel.get( "currentItem" );
        var baseUrl = "/manager/ajax/components";

        var result = {
            modalTitle: "",
            modifyUrl: "",
            readUrl: ""
        };

        if( current ) {

            switch( current.type ) {

            case "lineModel":

                result.modalTitle = "Componenti per " + current.line.name + " / " + current.model.name;
                result.readUrl = baseUrl + "?by=linemodel&lineId=" + current.line.id + "&modelId=" + current.model.id;
                result.modifyUrl = result.readUrl;

                break;

            case "item": // productItem

                console.log( "curr", current );

                result.modalTitle = "Componenti per elemento: " + current.attribute.name + " / " + current.attributeValue.rawValue.name;
                result.readUrl = baseUrl + "?by=item&&itemId=" + current.item.id;
                result.modifyUrl = result.readUrl;

                break;

            case "product":

                result.modalTitle = "Componenti base per il prodotto: " + current.product.name;
                result.readUrl = baseUrl + "?by=product&productId=" + current.product.id;
                result.modifyUrl = result.readUrl;

                break;

            case "attributeValue":

                result.modalTitle = "Componenti base per il valore: " + current.attribute.name + " / " + current.rawValue.name;
                result.readUrl = baseUrl + "?by=attributeValue&attributeValueId=" + current.attributeValue.id;
                result.modifyUrl = result.readUrl;

                break;

            default:
            }

        }

        return result;

    };

    var createCode = function( row ) {

        var code = row.rawProduct.id + "$$$" + row.color.id + "$$$" + row.variant.id;

        return code;

    };

    var viewModel = kendo.observable( {

        components: undefined,
        variants: [],
        selected: dataSources.selected,

        colors: [],
        showColors: false,
        showSearchPanel: true,
        variantsTitle: "Varianti",
        currentVariant: {},
        currentProduct: {},

        currentItem: undefined,

        showSearchResult: function() {

            return viewModel.get( "components" )?.total() > 0;

        },

        resetFilterSelected: function() {

            var dataSource = viewModel.get( "selected" );

            var thisForm = $( "#component-list-selected-form" );

            thisForm.find( "input[name=str]" ).val( "" );

            dataSource.filter( [] );
            dataSource.view();

            return false;
        },

        copy: function() {

            var checks = $( "#component-list-selected-form input[name=selected]:checked" );

            console.log( "checks", checks.length );

            if ( !checks.length ) {
                AP.widget.autoClearMessage(
                    "components-status-selected",
                    "<span class='auto-clear-status error'>Seleziona almeno un componente</span>"
                );
                return false;
            }

            var data = viewModel.get( "selected" ).data().toJSON();
            var result = [];

            for ( var row of data ) {

                for ( var check of checks ) {
                    check = $( check );
                    if ( row.id == check.val() ) {
                        result.push( row );
                    }
                }

            }

            NM.util.copyText( JSON.stringify( result ) );

            AP.widget.autoClearMessage(
                "components-status-selected",
                "<span class='auto-clear-status success'>Hai copiato " + result.length +  " combinazioni.</span>"
            );

            return false;
        },

        paste: function() {

            // Prova a leggere dal clipboard
            if ( window.navigator.clipboard && window.navigator.clipboard.readText ) {
                window.navigator.clipboard.readText()
                    .then( clipboardText => {
                        processPastedData( clipboardText );
                    } )
                    .catch( err => {
                        console.error( "Errore nella lettura del clipboard:", err );
                        fallbackPaste();
                    } );
            } else {
                // Fallback per browser che non supportano clipboard API
                fallbackPaste();
            }

            function processPastedData( clipboardText ) {
                // try {
                // Prova a parsare come JSON
                var data = JSON.parse( clipboardText );

                console.log( "Dati dal clipboard:", data );

                // Aggiungi i dati al dataSource
                var dataSource = viewModel.get( "selected" );

                if ( Array.isArray( data ) ) {
                    // Se è un array, aggiungi tutti gli elementi
                    for ( var item of data ) {
                        if ( item.typeId == "base" ) {
                            item.override.id = "";
                        } else {
                            item.id = "";
                        }

                        if ( item.typeId == "base" ) {
                            for ( var thisItem of dataSource.data() ) {
                                if ( item.id == thisItem.id ) {
                                    var dsItem = dataSource.getByUid( thisItem.uid );
                                    dsItem.set( "override.quantity", item.override.quantity );
                                    dsItem.set( "override.deleted", item.override.deleted );
                                }
                            }
                        } else {
                            dataSource.add( item );
                        }

                    }

                    alert( "Aggiunti " + data.length + " elementi dal clipboard" );
                }
                /*
                    } else {
                        // Se è un singolo oggetto, aggiungilo
                        if ( data.typeId == "base" ) {
                            data.override.id = ""; // Resetta l'ID solo per typeId "base"
                        }
                        dataSource.add( data );
                        alert( "Aggiunto 1 elemento dal clipboard" );
                    }
                    */

                // } catch ( error ) {
                // console.error( "Il testo nel clipboard non è un JSON valido:", error );
                // alert( "Il contenuto del clipboard non è in formato JSON valido" );
                // }
            }

            function fallbackPaste() {
                // Crea un textarea temporaneo per il paste manuale
                var textArea = document.createElement( "textarea" );
                textArea.placeholder = "Incolla qui i dati JSON...";
                textArea.style.width = "400px";
                textArea.style.height = "200px";

                var modal = document.createElement( "div" );
                modal.style.position = "fixed";
                modal.style.top = "50%";
                modal.style.left = "50%";
                modal.style.transform = "translate(-50%, -50%)";
                modal.style.background = "white";
                modal.style.padding = "20px";
                modal.style.border = "2px solid #ccc";
                modal.style.borderRadius = "5px";
                modal.style.zIndex = "9999";
                modal.style.boxShadow = "0 4px 8px rgba(0,0,0,0.2)";

                var title = document.createElement( "h3" );
                title.textContent = "Incolla dati manualmente";

                var buttonContainer = document.createElement( "div" );
                buttonContainer.style.marginTop = "10px";

                var pasteBtn = document.createElement( "button" );
                pasteBtn.textContent = "Incolla";
                pasteBtn.className = "btn btn-primary";
                pasteBtn.style.marginRight = "10px";
                pasteBtn.onclick = function() {
                    var text = textArea.value.trim();
                    if ( text ) {
                        processPastedData( text );
                    }
                    document.body.removeChild( modal );
                };

                var cancelBtn = document.createElement( "button" );
                cancelBtn.textContent = "Annulla";
                cancelBtn.className = "btn";
                cancelBtn.onclick = function() {
                    document.body.removeChild( modal );
                };

                buttonContainer.appendChild( pasteBtn );
                buttonContainer.appendChild( cancelBtn );

                modal.appendChild( title );
                modal.appendChild( textArea );
                modal.appendChild( buttonContainer );

                document.body.appendChild( modal );
                textArea.focus();
            }

            return false;
        },

        selectAll: function( event ) {

            console.log( "event", event );

            NM.util.checkAll( event.currentTarget );

            return false;
        },

        filterSelected: function() {

            var thisForm = $( "#component-list-selected-form" );
            var dataSource = viewModel.get( "selected" );

            var str = thisForm.find( "input[name=str]" ).val();
            var typeId = thisForm.find( "select[name=processingTypeId]" ).val();

            var filter = {
                logic: "or",
                filters: []
            };

            if ( str.length ) {
                filter.filters.push( { field: "rawProduct.id", operator: "contains", value: str } );
                filter.filters.push( { field: "rawProduct.name", operator: "contains", value: str } );
            };

            if ( typeId.length ) {
                filter.filters.push( { field: "rawProduct.processingType.id", operator: "eq", value: typeId } );
            };

            dataSource.filter( filter );

            dataSource.view();

            return false;
        },

        showVariants: function() {

            return !viewModel.get( "showSearchPanel" );
        },

        addColor: function( event ) {

            var color = event.data;

            var product = viewModel.get( "currentProduct" );
            var variant = viewModel.get( "currentVariant" );

            var row = {
                id: "",
                typeId: "own",
                quantity: 1,
                rawProduct: {
                    id: product.id,
                    name: product.name,
                    processingType: {
                        id: product.processingType.id,
                        name: product.processingType.name
                    },
                    measurementUnit: {
                        id: product.measurementUnit.id,
                        name: product.measurementUnit.name
                    }
                },
                color: {
                    id: color.id,
                    name: color.name
                },
                variant: {
                    id: variant.id,
                    name: variant.name
                }
            };

            row.code = createCode( row );

            var exists = selectedExists( row );

            if( exists ) {
                AP.widget.autoClearMessage( "components-status-selected", "<span class='auto-clear-status error'>È stato già aggiunto</span>" );
            } else {
                viewModel.get( "selected" ).add( row );
            }

            return false;
        },

        search: function( event ) {

            var thisForm = $( "#component-list-search-form" );
            var status = thisForm.find( ".status" );

            var requestStart = function() {
                status.html( "Sto cercando..." );
            };

            var requestEnd = function( xhr ) {
                status.html( "Ho trovato " + xhr.response.total + " componenti" );
            };

            var params = thisForm.serializeJSON();

            var dataSource = NM.kendo.dataSource( {
                url: "/manager/ajax/raw-products",
                params: params,
                requestEnd: requestEnd,
                requestStart: requestStart
            } );

            viewModel.set( "components", dataSource );

            return false;

        },

        save: function( event ) {

            NM.util.ajax( {
                method: "POST",
                url: getCurrentConfig().modifyUrl,
                data: JSON.stringify( viewModel.get( "selected" ).data() ),
                callback: {
                    done: function( xhr ) {

                        if( xhr.status == "SUCCESS" ) {

                            AP.widget.notify( "success", "Configurazione salvata" );

                            refreshSelectedComponents();

                        }

                    }
                }
            } );

            return false;

        },

        openColors: function( event ) {

            viewModel.set( "currentVariant", event.data );
            viewModel.set( "colors", event.data.colors );

            return false;
        },

        openVariants: function( event ) {

            viewModel.set( "currentProduct", event.data );

            viewModel.set( "showSearchPanel", false );
            viewModel.set( "variantsTitle", "Varianti per " + event.data.name + " <small>(" + event.data.id + ")</small>" );
            viewModel.set( "variants", event.data.variants );

            viewModel.set( "colors", [] );

            return false;
        },

        showComponentsList: function( event ) {

            viewModel.set( "showSearchPanel", true );

            return false;
        },

        calcTotalQuantity: function( event ) {

            console.log( "calcTotalQuantity", event );

            var dataSource = viewModel.get( "selected" );

            var item = dataSource.getByUid( event.data.uid );

            var quantityOverride = item.get( "override.quantity" ) ? item.get( "override.quantity" ) : 0;

            console.log( "quantityOverride", quantityOverride );

            var totalQuantity = math.add( quantityOverride, item.get( "quantity" ) );

            item.set( "totalQuantity", totalQuantity );

            return false;

        },

        showVariantsForCount: function( event ) {

            return event.variants.length > 0;

        },

        showColorsResult: function( event ) {

            $( "#components-colors-list-modal" ).modal( "show" );

            return false;
        },

        showSelectedTable: function() {

            var dataSource = viewModel.get( "selected" );

            return dataSource.total() > 0;

        },

        remove: function( event ) {

            var dataSource = viewModel.get( "selected" );

            var row = dataSource.getByUid( event.data.uid );

            dataSource.remove( row );

            return false;

        },

        deactivate: function( event ) {

            var dataSource = viewModel.get( "selected" );

            var row = dataSource.getByUid( event.data.uid );
            var value = row.get( "override.deleted" );

            row.set( "override.deleted", value ? false : true );

            return false;

        },

        getModalTitle: function( event ) {

            var name = getCurrentConfig().modalTitle;

            return name;

        },

    } );

    var refreshSelectedComponents = function( onDone ) {

        // console.log("refreshSelectedComponents:onDone", onDone);

        NM.util.ajax( {
            method: "GET",
            url: getCurrentConfig().readUrl,
            callback: {
                done: function( xhr ) {

                    viewModel.get( "selected" ).data( xhr.data );

                    if( onDone ) {
                        onDone();
                    }

                }
            }
        } );

    };

    pub.open = function( item ) {

        viewModel.set( "currentItem", item );

        viewModel.set( "colors", [] );
        viewModel.set( "variants", [] );

        viewModel.showComponentsList();

        var onDone = function() {
            NM.util.openModal( $( "#component-list-modal" ) );
            // console.log("done")
        };

        refreshSelectedComponents( onDone=onDone );

    };

    pub.init = function() {

        kendo.bind( fields.rootList, viewModel );

    };

    return pub;

}() );