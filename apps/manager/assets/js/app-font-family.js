AP.fontFamily = AP.fontFamily || {};

AP.fontFamily.fields = {
    listRoot: $( "#font-family-list-root" ),
    searchListForm: $( "#font-family-grid-search-form" ),
    detailRoot: $( "#font-family-detail-modal" ),
    detailForm: $( "#font-family-detail-form" ),
    pictogramRoot: $( "#pictogram-root" ),
    pictogramModal: $( "#pictogram-modal" ),
    pictogramForm: $( "#pictogram-form" ),
    pictogramDimensionsRoot: $( "#pictogram-dimensions-root" )
};

$( document ).ready( function() {
    if ( AP.fontFamily.fields.listRoot.length ) {
        AP.fontFamily.list.init();
    }
    if ( AP.fontFamily.fields.detailRoot.length ) {
        AP.fontFamily.detail.init();
        $( "#addSize i" ).after( " Aggiungi Dimensione" );
    }
    if ( AP.fontFamily.fields.pictogramRoot.length ) {
        AP.fontFamily.pictogram.init();
    }
} );

AP.fontFamily.detail = ( function() {
    var pub = {};

    var fields = AP.fontFamily.fields;

    var defaultDetailForm = {
        data: {
            id: "",
            code: "",
            name: "",
            sizes: new kendo.data.DataSource()
        },
        title: "Carica Font Family",
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        resetForm: function() {
            var detailForm = fields.detailForm;
            // viewModel.get( 'sizes' ).data( new kendo.data.DataSource() );

            NM.form.clearMessages( fields.detailForm );

            viewModel.set( "detailForm", defaultDetailForm );
        },

        addSize: function( event ) {
            viewModel.get( "detailForm.data.sizes" ).add( { id: "", name: "" } );
        },

        removeSize: function( event ) {
            const name = event.data.name;
            const id = event.data.id;

            if ( id && id != "" ) {
                bootbox.confirm( {
                    title: "Conferma cancellazione",
                    message: "Sei sicuro di voler cancellare la dimensione " + name + "?",
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

                        if ( result ) { // true

                            NM.util.ajax( {
                                method: "DELETE",
                                url: "/manager/ajax/font-family-sizes",
                                data: { "fontFamilySizeId": id },
                                callback: {
                                    done: function( xhr ) {

                                        viewModel.get( "detailForm.data.sizes" ).remove( event.data );

                                        AP.widget.notify(
                                            "success",
                                            "Dimensione " + name + " cancellata con successo",
                                        );
                                    }
                                }
                            } );

                        }
                    },
                } );
            }
        },

        save: function( event ) {
            var detailForm = fields.detailForm;
            var status = detailForm.find( ".status" );

            status.html(
                "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>",
            );

            if ( detailForm.valid() ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/font-families",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {

                                status.html( "" );

                                AP.widget.notify( "success", xhr.data.message.text );

                                setTimeout( () => {
                                    fields.detailRoot.modal( "hide" );

                                	AP.util.fireCallback( "onSave", viewModel.get( "callback" ) );

                                }, 700 );

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

        NM.util.openModal( fields.detailRoot );
    };

    pub.edit = function( id, onSave ) {
        viewModel.resetForm();

        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/font-families/" + id,
            callback: {
                done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {

                        viewModel.set( "detailForm.data.id", xhr.data.id );
                        viewModel.set( "detailForm.data.code", xhr.data.code );
                        viewModel.set( "detailForm.data.name", xhr.data.name );
                        viewModel.get( "detailForm.data.sizes" ).data( xhr.data.sizes );

                        viewModel.set( "detailForm.title", "Modifica Font Family < " + xhr.data.name + " >" );

                    }
                },
            },
        } );

        NM.util.openModal( fields.detailRoot );
    };

    pub.init = function() {
        kendo.bind( fields.detailRoot, viewModel );

        var detailForm = fields.detailForm;

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                name: {
                    required: true,
                },
                code: {
                    required: true,
                    checkCode: true,
                    rangelength: [ 5, 5 ],
                    remote: {
                        url: "/manager/ajax/font-families/code-exists",
                        data: {
                            id: function() {
                                return viewModel.get( "detailForm.data.id" );
                            }
                        },
                        dataFilter: function( xhr ) {
                            var json = JSON.parse( xhr );
                            return json.data == false;
                        },
                    },
                },
            },
            messages: {
                name: {
                    required: "Nome richiesto",
                },
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

AP.fontFamily.pictogram = ( function() {
    var pub = {};
    var fields = AP.fontFamily.fields;

    var defaultDetailForm = {
        data: {
            id: "",
            name: "",
            fontFamilyPictograms: new kendo.data.DataSource(),
            pictogram: {
                id: "",
                name: "",
                image: null
            }
        },
        title: "Pittogrammi",
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,
        pictograms: new kendo.data.DataSource(),
        dimensions: new kendo.data.DataSource(),
        currentPictogramId: null,
        titleDimensionModal: "",
        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        editDimensions: function( event ) {

            var thisId = event.data.id;

            NM.util.ajax( {
                method: "GET",
                url: `/manager/ajax/pictograms/${thisId}/dimensions`,
                callback: {
                    done: function( xhr ) {
                        viewModel.set( "titleDimensionModal", "Dimensioni" );
                        viewModel.get( "dimensions" ).data( xhr.data );
                        viewModel.set( "currentPictogramId", thisId );

                    },
                },
            } );

            NM.util.openModal( fields.pictogramDimensionsRoot );
        },

        saveDimensions: function() {

            NM.util.ajax( {
                method: "POST",
                url: `/manager/ajax/pictograms/${viewModel.get( "currentPictogramId" )}/dimensions`,
                data: JSON.stringify( viewModel.get( "dimensions" ).data() ),
                callback: {
                    done: function( xhr ) {
                        AP.widget.notify( "success", "Dimensioni salvate" );
                    },
                },
            } );

        },

        resetForm: function() {
            var detailForm = fields.pictogramForm;

            NM.form.clearMessages( detailForm );

            $( "#pictogramFileUpload" ).val( "" );

            viewModel.set( "detailForm", defaultDetailForm );
        },

        remove: function( event ) {
            const name = event.data.name;
            const id = event.data.id;

            if ( id && id != "" ) {
                bootbox.confirm( {
                    title: "Conferma cancellazione",
                    message: "Sei sicuro di voler cancellare il pittogramma " + name + "?",
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

                        if ( result ) { // true

                            NM.util.ajax( {
                                method: "DELETE",
                                url: "/manager/ajax/pictograms",
                                data: { "pictogramId": id },
                                callback: {
                                    done: function( xhr ) {

                                        AP.widget.notify( "success", "Pittogramma " + name + " cancellato con successo" );

                                        var fontFamilyId = viewModel.get( "detailForm.data.id" );
                                        var fontFamilyName = viewModel.get( "detailForm.data.name" );

                                        pub.edit( fontFamilyId, fontFamilyName );


                                    }
                                }
                            } );

                        }
                    },
                } );
            }

        },

        save: function( event ) {
            var detailForm = fields.pictogramForm;
            var status = detailForm.find( ".status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            if ( detailForm.valid() ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/pictograms",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                NM.util.autoHideMessage(
                                    status,
                                    "<span class='green'>Pittogramma salvato</span>",
                                );

                                var fontFamilyId = viewModel.get( "detailForm.data.id" );
                                var fontFamilyName = viewModel.get( "detailForm.data.name" );

                                NM.util.ajax( {
                                    method: "GET",
                                    url: `/manager/ajax/font-family/${fontFamilyId}/pictograms`,
                                    callback: {
                                        done: function( xhr ) {
                                            if ( xhr.status == "SUCCESS" ) {
                                                pub.edit( fontFamilyId, fontFamilyName );
                                            }
                                        },
                                    },
                                } );
                            }
                        },
                    },
                } );
            }

            return false;
        },
    } );

    pub.edit = function( id, name ) {
        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: `/manager/ajax/font-family/${id}/pictograms`,
            callback: {
                done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {

                        viewModel.get( "detailForm.data.fontFamilyPictograms" ).data( xhr.data );
                        viewModel.set( "detailForm.title", "Pittogrammi per < " + name + " >" );

                        var allPictograns = AP.page.pictogramCodes;
                        const filtered = allPictograns.filter( function( p ) {
                            return !xhr.data.some( s => s.code === p.id );
                        } );

                        viewModel.set( "pictograms", filtered );

                        NM.util.openModal( fields.pictogramModal );

                    }
                },
            },
        } );

        $( "#pictogramFileUpload" ).on( "change", function( e ) {

            const file = e.target.files[0];

            if ( file ) {
                const reader = new FileReader();
                reader.readAsDataURL( file );
                reader.onload = function( evt ) {
                    const base64 = evt.target.result;
                    viewModel.set( "detailForm.data.pictogram.image", base64 );
                    // viewModel.checkCanSave();
                };

            }
        } );

        viewModel.set( "detailForm.data.id", id );
        viewModel.set( "detailForm.data.name", name );
    };

    pub.init = function() {
        kendo.bind( fields.pictogramRoot, viewModel );

        AP.page.pictogramCodes.unshift( { "id": "", "name": "--" } );
        viewModel.set( "pictograms", AP.page.pictogramCodes );

        var pictogramForm = fields.pictogramForm;

        pictogramForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                pictogramFileUpload: {
                    required: true,
                    extension: "svg"
                },
                pictogramCode: {
                    required: true,
                },
            },
            messages: {
                pictogramFileUpload: {
                    required: "File richiesto",
                    extension: "Solo nel formato SVG",
                },
                pictogramCode: {
                    required: "Seleziona un pittogramma",
                },
            },
        } );
    };

    return pub;
} () );

AP.fontFamily.list = ( function() {
    var pub = {};

    var fields = AP.fontFamily.fields;
    var detailApp = AP.fontFamily.detail;
    var pictogramApp = AP.fontFamily.pictogram;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/font-families" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            var thisForm = fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

        new: function( event ) {
            var onSave = function() {
                viewModel.get( "rows" ).read();
            };

            detailApp.new( onSave );

            return false;
        },


        edit: function( event ) {
            var onSave = function() {
                viewModel.get( "rows" ).read();
            };

            detailApp.edit( event.data.id, onSave );

            return false;
        },

        editPictograms: function( event ) {

            pictogramApp.edit( event.data.id, event.data.name );

            return false;
        },

        delete: function( event ) {
            var checks = $( "#font-family-grid" ).find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/font-families",
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
                            viewModel.rows.read();
                        },
                    },
                } );
            } else {
                AP.widget.notify( "warning", "Seleziona almeno un valore" );
            }
        }
    } );

    pub.init = function() {
        kendo.bind( AP.fontFamily.fields.listRoot, viewModel );
    };

    return pub;
} () );