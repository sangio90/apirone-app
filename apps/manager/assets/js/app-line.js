AP.line = AP.line || {};

AP.line.fields = {
    listRoot: $( "#line-list-root" ),
    detailRoot: $( "#line-detail-modal" ),
    detailForm: $( "#line-detail-form" ),
    searchListForm: $( "#line-grid-search-form" ),
    productsRoot: $( "#line-products-root" ),
    modelConfigModal: $( "#model-config-modal" ),
    modelConfigForm: $( "#model-config-form" ),
};

$( document ).ready( function() {
    if ( AP.line.fields.listRoot.length ) {
        AP.line.list.init();
    }

    if ( AP.line.fields.productsRoot.length ) {
        AP.line.products.init();
    }

    if ( AP.line.fields.detailRoot.length ) {
        AP.line.detail.init();
    }
} );

AP.line.detail = ( function() {
    var pub = {};

    var defaultDetailForm = {
        data: {
            id: "",
            code: "",
            name: "",
            hscode: "",
            selectedCategories: [],
            category: {
                id: "",
            },
            nameItem: {
                id: "",
                name: "",
                lang: {
                    id: "IT"
                }
            },
            descriptionItem: {
                id: "",
                name: "",
                lang: {
                    id: "IT"
                }
            },
            status: {
                id: "ACT",
            },
        },
        statuses: AP.page.statuses,
        categories: AP.page.categories,
        thicknesses: AP.page.thicknesses,
        title: "Carica linea",
    };

    // Helper per estrarre la traduzione
    function getText( texts, kind, lang ) {
        return texts.find(
            t => t.kind === kind && t.lang && t.lang.id === lang
        ) || { name: "" };
    }

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        // TESTARE
        getText: getText,

        // TESTARE
        setTextName: function( kind, lang, value ) {
            var texts = this.get( "detailForm.data.texts" );
            var item = texts.find( t => t.kind === kind && t.lang && t.lang.id === lang );
            if ( item ) {
                item.name = value;
                this.trigger( "change", { field: "detailForm.data.texts" } );
            }
        },

        resetForm: function() {
            var detailForm = AP.line.fields.detailForm;

            var validator = detailForm.validate();
            validator.resetForm();

            detailForm.find( ".status" ).html( "" );

            viewModel.set( "detailForm", defaultDetailForm );
        },

        save: function( event ) {
            var detailForm = AP.line.fields.detailForm;
            var status = detailForm.find( ".status" );

            status.html(
                "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>",
            );

            if ( detailForm.valid() ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/lines",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                NM.util.autoHideMessage(
                                    status,
                                    "<span class='green'>Linea salvata</span>",
                                );

                                setTimeout(
                                    () => $( "#line-detail-modal" ).modal( "hide" ),
                                    1000,
                                );

                                AP.util.fireCallback(
                                    "onSave",
                                    viewModel.get( "callback" ),
                                );
                            }
                        },
                    },
                } );
            }

            return false;
        },
    } );

    pub.new = function( { onSave } ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.openModal( AP.line.fields.detailRoot );
    };

    pub.edit = function( { id, onSave } ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/lines/" + id,
            callback: {
                done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {
                        var selectedCategories = [];

                        if ( xhr.data?.categories ) {
                            for ( var category of xhr.data.categories ) {
                                selectedCategories.push( category );
                            }
                        }

                        viewModel.set( "detailForm.data", xhr.data );
                        viewModel.set(
                            "detailForm.data.selectedCategories",
                            selectedCategories,
                        );
                        viewModel.set( "detailForm.title", "Modifica linea" );

                        NM.util.openModal( AP.line.fields.detailRoot );
                    }
                },
            },
        } );
    };

    pub.init = function() {
        kendo.bind( AP.line.fields.detailRoot, viewModel );

        AP.page.categories.unshift( {
            id: "",
            name: "-- Seleziona una categoria",
        } );

        AP.page.thicknesses.unshift( {
            id: "",
            name: "-- Seleziona uno spessore",
        } );

        var detailForm = AP.line.fields.detailForm;

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                code: {
                    required: true,
                    checkCode: true,
                    rangelength: [ 5, 5 ],
                    remote: {
                        url: "/manager/ajax/lines/code-exists",
                        data: {
                            id: function() {
                                return viewModel.get( "detailForm.data.id" );
                            },
                        },
                        dataFilter: function( xhr ) {
                            var json = JSON.parse( xhr );
                            return json.data == false;
                        },
                    },
                },
            },
            messages: {
                code: {
                    required: "Codice richiesto",
                    rangelength: "Sono richiesti 5 caratteri",
                    checkCode: "Solo numeri, lettere, trattino o trattino basso",
                    remote: "Il codice esiste",
                },
            },
        } );
    };

    return pub;
} () );

AP.line.list = ( function() {
    var pub = {};

    var detailApp = AP.line.detail;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/lines" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            var thisForm = AP.line.fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

        new: function( event ) {
            console.log( "detailApp", detailApp );

            var onSave = function() {
                console.log( "onSave" );
                viewModel.get( "rows" ).read();
            };

            detailApp.new( { onSave: onSave } );

            return false;
        },

        edit: function( event ) {
            var onSave = function() {
                viewModel.get( "rows" ).read();
            };

            detailApp.edit( { id: event.data.id, onSave: onSave } );

            return false;
        },

        delete: function( event ) {
            var checks = $( "#line-grid" ).find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/lines",
                    data: ids,
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                                AP.widget.notify(
                                    "error",
                                    "Non riesco a cancellare tutti i valori",
                                );
                            } else {
                                AP.widget.notify(
                                    "success",
                                    "Cancellazione avvenuta con successo",
                                );
                            }

                            var id = viewModel.get( "detailForm.data.id" );
                            console.log( "id", id );

                            viewModel.rows.read();
                        },
                    },
                } );
            } else {
                AP.widget.notify( "warning", "Seleziona almeno un valore" );
            }
        },

        products: function( event ) {
            var id = event.data.id;
            window.open( "/manager/lines/" + id + "/products", "_blank" ).focus();

            return false;
        },

        attributes: function( event ) {

            var id = event.data.id;
            window.open( "/manager/lines/" + id + "/attributes", "_blank" ).focus();

            return false;
        },
    } );

    pub.init = function() {
        kendo.bind( AP.line.fields.listRoot, viewModel );
    };

    return pub;
} () );

AP.line.products = ( function() {
    var pub = {};
    var fields = AP.line.fields;

    var defaultModelConfigModal = {
        title: "Configura dimensioni",
        data: {
            height: "",
            width: "",
            length: "",
        },
    };

    var changeStatus = function( status, event ) {
        // active
        var method = "POST";
        var classToShow = "active";
        var classToHide = "deactive";
        var message = "Combinazione salvata";

        // deactive
        if ( status == "deactive" ) {
            method = "DELETE";
            classToShow = "deactive";
            classToHide = "active";
            message = "Combinazione rimossa";
        }

        var ele = $( event.currentTarget );

        var status = $( "#line-products-status" );
        var values = ele.data( "values" );
        var category = ele.data( "category" );

        status.html( "<img src='/assets/main/img/ajax-loading.svg' width=20 height=20>" );

        var model = values.split( "__" )[0];
        var finish = values.split( "__" )[1];

        NM.util.ajax( {
            method: method,
            url: "/manager/ajax/lines/" + AP.page.line.id + "/products",
            data: JSON.stringify( {
                modelId: model,
                finishId: finish,
                categoryId: category,
            } ),
            callback: {
                done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {
                        var button = $( "button[data-values='" + values + "']" );

                        button.filter( "." + classToShow ).show();
                        button.filter( "." + classToHide ).hide();

                        status.html( "<span class='green'>" + message + "</span> " );
                    }
                },
            },
        } );

        return false;
    };

    var generateTableStyles = function() {
        var maxColumns = 30; // il numero massimo previsto
        var style = "";

        for ( let n = 1; n <= maxColumns; n++ ) {
            style += `.table-header-fixed:has(tbody tr > *:nth-child(${n}):hover) tr>*:nth-child(${n}):not(.no-highlight) { background: var(--col); }\n`;
        }

        var sheet = document.createElement( "style" );

        sheet.innerHTML = style;
        document.head.appendChild( sheet );
    };

    var viewModel = kendo.observable( {
        modelConfigModal: defaultModelConfigModal,

        attributes: function( event ) {
            var lineId = window.location.href.split( "/" )[5];
            var categoryId = window.location.href.split( "/" )[7];

            console.log( "lineId", lineId );
            console.log( "categoryId", categoryId );

            window.open( "/manager/lines/" + lineId + "/categories/" + categoryId + "/attributes", "_blank" ).focus();

            return false;
        },

        activate: function( event ) {
            event.preventDefault();

            changeStatus( "active", event );
        },

        deactivate: function( event ) {
            event.preventDefault();

            bootbox.confirm( {
                title: "Conferma eliminazione",
                message: "Sei sicuro di voler cancellare questo prodotto?",
                buttons: {
                    confirm: {
                        label: "Si, confermo",
                        className: "btn-primary",
                    },
                    cancel: {
                        label: "No, chiudi",
                        className: "btn-danger",
                    },
                },
                callback: function( result ) {
                    if ( result ) {
                        changeStatus( "deactive", event );
                    }
                },
            } );
        },

        showModelConfigModal: function( event ) {
            NM.util.openModal( fields.modelConfigModal );

            const lineId = $( event.currentTarget ).data( "line-id" );
            const productCategoryId = $( event.currentTarget ).data(
                "product-category-id",
            );
            const modelId = $( event.currentTarget ).data( "model-id" );
            const modelConfigId = $( event.currentTarget ).data( "model-config-id" );
            const width = $( event.currentTarget ).data( "width" );
            const height = $( event.currentTarget ).data( "height" );
            const length = $( event.currentTarget ).data( "length" ) || "";

            viewModel.set( "modelConfigModal.data.modelId", modelId );
            viewModel.set(
                "modelConfigModal.data.productCategoryId",
                productCategoryId,
            );
            viewModel.set( "modelConfigModal.data.modelConfigId", modelConfigId );
            viewModel.set( "modelConfigModal.data.lineId", lineId );
            viewModel.set( "modelConfigModal.data.width", width );
            viewModel.set( "modelConfigModal.data.height", height );
            viewModel.set( "modelConfigModal.data.length", length );

            return false;
        },

        saveModelConfig: function( event ) {
            var modelConfigForm = AP.line.fields.modelConfigForm;
            var status = modelConfigForm.find( ".status" );

            status.html(
                "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>",
            );

            if ( modelConfigForm.valid() ) {
                const modelConfigFormData = viewModel.get( "modelConfigModal.data" );
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/model-config",
                    data: JSON.stringify( modelConfigFormData ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                NM.util.autoHideMessage(
                                    status,
                                    "<span class='green'>Dimensioni salvate</span>",
                                );

                                setTimeout(
                                    () => $( "#model-config-modal" ).modal( "hide" ),
                                    1000,
                                );


                                var callback = viewModel.isUpdate() ? "onUpdate" : "onCreate";
                                AP.util.fireCallback( callback, viewModel.get( "callback" ) );

                            }
                        },
                    },
                } );
            }

            return false;
        },
    } );

    pub.init = function() {

        var $table = $( ".table-header-fixed" );
        $table.floatThead( { top: 94 } );

        generateTableStyles();

        kendo.bind( fields.productsRoot, viewModel );

        var modelConfigForm = fields.modelConfigForm;

        var validateRules = {
            width:  { required: true, number: true },
            height: { required: true, number: true },
        };
        var validateMessages = {
            width:  { required: "Larghezza richiesta.", number: "Inserisci un numero valido." },
            height: { required: "Altezza richiesta.",  number: "Inserisci un numero valido." },
        };
        if ( modelConfigForm.find( "[name='length']" ).length ) {
            validateRules.length    = { required: true, number: true };
            validateMessages.length = { required: "Lunghezza richiesta.", number: "Inserisci un numero valido." };
        }

        modelConfigForm.validate( {
            rules:    validateRules,
            messages: validateMessages,
        } );
    };

    return pub;
} () );
