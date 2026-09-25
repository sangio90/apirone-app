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
            sizes: new kendo.data.DataSource(),
            // file del font già salvato (dal server) e, se scelto, quello nuovo da caricare
            fontFile: { uri: "", name: "" },
            fontFileUpload: null, // { fileName, content (data URL) }
            removeFontFile: false
        },
        title: "Carica Font Family",
    };

    // Anteprima del file del font nella modale: lo carica nel browser con la FontFace API
    // (stesso meccanismo dell'anteprima segnaletica), senza bisogno di installarlo.
    var previewFontFile = function( url ) {
        var preview = $( "#font-family-file-preview" );
        if ( !url ) {
            preview.hide();
            return;
        }
        var alias = "apirone-ff-preview-" + Date.now();
        new FontFace( alias, "url(" + JSON.stringify( url ) + ")" ).load().then( function( face ) {
            document.fonts.add( face );
            preview.css( "font-family", "\"" + alias + "\"" ).show();
        } ).catch( function() {
            preview.hide();
            AP.widget.notify( "error", "Impossibile leggere il file del font." );
        } );
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
            viewModel.set( "detailForm.data.fontFile", { uri: "", name: "" } );
            viewModel.set( "detailForm.data.fontFileUpload", null );
            viewModel.set( "detailForm.data.removeFontFile", false );
            $( "#fontFamilyFileUpload" ).val( "" );
            previewFontFile( null );
        },

        hasFontFile: function() {
            return !!this.get( "detailForm.data.fontFile.uri" );
        },

        removeFontFile: function() {
            viewModel.set( "detailForm.data.fontFile", { uri: "", name: "" } );
            viewModel.set( "detailForm.data.fontFileUpload", null );
            viewModel.set( "detailForm.data.removeFontFile", true );
            $( "#fontFamilyFileUpload" ).val( "" );
            previewFontFile( null );
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
                            // es. file del font in formato non supportato (controllo lato server)
                            if ( xhr.status == "INVALID" ) {
                                status.html( "" );
                                NM.form.showMessages( xhr.data );
                                return;
                            }
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
                        viewModel.set( "detailForm.data.fontFile", xhr.data.fontFile && xhr.data.fontFile.uri ? xhr.data.fontFile : { uri: "", name: "" } );
                        previewFontFile( viewModel.get( "detailForm.data.fontFile.uri" ) );

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

        // File del font scelto: letto come data URL, inviato con il save della famiglia
        $( "#fontFamilyFileUpload" ).on( "change", function( event ) {
            var file = event.target.files[0];
            if ( !file ) {
                viewModel.set( "detailForm.data.fontFileUpload", null );
                previewFontFile( viewModel.get( "detailForm.data.fontFile.uri" ) );
                return;
            }
            var ext = file.name.split( "." ).pop().toLowerCase();
            if ( [ "woff2", "woff", "ttf", "otf" ].indexOf( ext ) === -1 ) {
                AP.widget.notify( "error", "Formato non supportato: usare woff2, woff, ttf o otf." );
                $( this ).val( "" );
                return;
            }
            var reader = new FileReader();
            reader.onload = function( evt ) {
                viewModel.set( "detailForm.data.fontFileUpload", { fileName: file.name, content: evt.target.result } );
                viewModel.set( "detailForm.data.removeFontFile", false );
                previewFontFile( evt.target.result );
            };
            reader.readAsDataURL( file );
        } );

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                name: {
                    required: true,
                },
                // jQuery Validate trasforma l'attributo accept=".woff2,..." dell'input nella
                // regola "accept", che controlla il MIME type: per i font i browser riportano
                // tipi vuoti o non standard e la validazione fallisce appena si sceglie il file
                // ("Please enter a value with a valid mimetype"). false = regola disattivata;
                // il formato è già controllato dall'handler change e lato server.
                fontFamilyFileUpload: {
                    accept: false,
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

    /*
        Analisi dell'SVG del pittogramma scelto, prima del caricamento:
        - solo immagine raster incorporata (<image>) senza forme vettoriali: rifiutato
          (tipico export sbagliato da Illustrator: nell'anteprima diventa un puntino ed è
          sgranato se ingrandito). Lo stesso controllo è fatto anche lato server.
        - disegno che occupa una piccola parte della tavola (viewBox): verrà mostrato molto
          più piccolo del previsto, si chiede conferma.
        Il bounding box reale si misura rendendo l'SVG in un contenitore nascosto (getBBox).
    */
    var MIN_ARTWORK_FILL = 0.5; // quota minima della tavola occupata dal disegno (sul lato maggiore)

    var analyzeSvg = function( svgText ) {
        var doc = new DOMParser().parseFromString( svgText, "image/svg+xml" );
        var svg = doc.documentElement;
        if ( doc.getElementsByTagName( "parsererror" ).length || !svg || svg.nodeName.toLowerCase() !== "svg" ) {
            return { error: "Il file non è un SVG valido." };
        }

        var hasVector = svg.querySelector( "path, polygon, polyline, rect, circle, ellipse, line, text, use" ) !== null;
        var hasRaster = svg.querySelector( "image" ) !== null;
        if ( !hasVector && hasRaster ) {
            return { error: "L'SVG contiene solo un'immagine raster incorporata, non forme vettoriali: riesportalo da Illustrator come vettoriale, con la tavola adattata al disegno." };
        }
        if ( !hasVector ) {
            return { error: "L'SVG non contiene alcun disegno." };
        }

        // tavola: viewBox, oppure width/height
        var vb = ( svg.getAttribute( "viewBox" ) || "" ).trim().split( /[\s,]+/ ).map( Number );
        var board = vb.length === 4 && vb[2] > 0 && vb[3] > 0
            ? { width: vb[2], height: vb[3] }
            : { width: parseFloat( svg.getAttribute( "width" ) ), height: parseFloat( svg.getAttribute( "height" ) ) };
        if ( !( board.width > 0 && board.height > 0 ) ) {
            return {}; // dimensioni tavola non determinabili: nessun controllo di riempimento
        }

        var host = document.createElement( "div" );
        host.style.cssText = "position:absolute; left:-10000px; top:0; width:500px; height:500px; visibility:hidden;";
        var live = document.importNode( svg, true );
        live.setAttribute( "width", "500" );
        live.setAttribute( "height", "500" );
        host.appendChild( live );
        document.body.appendChild( host );
        var bbox = null;
        try {
            bbox = live.getBBox();
        } catch ( e ) {
            bbox = null;
        }
        document.body.removeChild( host );

        if ( !bbox || !bbox.width || !bbox.height ) {
            return {};
        }
        var fill = Math.max( bbox.width / board.width, bbox.height / board.height );
        return { fill: fill, board: board, bbox: bbox };
    };

    var rejectPictogramFile = function( input, message ) {
        $( input ).val( "" );
        viewModel.set( "detailForm.data.pictogram.image", null );
        AP.widget.notify( "error", message, "SVG non valido" );
    };

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
                            // controllo dell'SVG lato server (vedi PictogramAjaxController.checkPictogramSvg)
                            if ( xhr.status == "INVALID" ) {
                                status.html( "" );
                                NM.form.showMessages( xhr.data );
                                return;
                            }
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

                        var allPictograms = AP.page.pictogramCodes;
                        const filtered = allPictograms.filter( function( p ) {
                            return !xhr.data.some( s => s.code === p.id );
                        } );

                        viewModel.set( "pictograms", filtered );

                        NM.util.openModal( fields.pictogramModal );

                    }
                },
            },
        } );

        // Listener ri-registrato a ogni apertura (pub.edit): off() per non accumularli
        $( "#pictogramFileUpload" ).off( "change.pictogram" ).on( "change.pictogram", function( event ) {
            const input = this;
            const file = event.target.files[0];

            viewModel.set( "detailForm.data.pictogram.image", null );
            if ( !file ) {
                return;
            }

            const accept = function() {
                const reader = new FileReader();
                reader.readAsDataURL( file );
                reader.onload = function( evt ) {
                    viewModel.set( "detailForm.data.pictogram.image", evt.target.result );
                };
            };

            file.text().then( function( svgText ) {
                const check = analyzeSvg( svgText );

                if ( check.error ) {
                    rejectPictogramFile( input, check.error );
                    return;
                }

                if ( check.fill !== undefined && check.fill < MIN_ARTWORK_FILL ) {
                    const pct = Math.round( check.fill * 100 );
                    bootbox.confirm( {
                        title: "Tavola SVG troppo grande",
                        message: "Il disegno occupa solo il " + pct + "% della tavola dell'SVG ("
                            + Math.round( check.bbox.width ) + "×" + Math.round( check.bbox.height ) + " su "
                            + Math.round( check.board.width ) + "×" + Math.round( check.board.height ) + "): "
                            + "nell'anteprima il pittogramma risulterà molto più piccolo del previsto.<br><br>"
                            + "Conviene riesportarlo con la tavola adattata al disegno. Caricarlo comunque?",
                        buttons: {
                            confirm: { label: "Carica comunque", className: "btn-primary" },
                            cancel: { label: "Annulla", className: "btn-default" },
                        },
                        callback: function( ok ) {
                            if ( ok ) {
                                accept();
                            } else {
                                $( input ).val( "" );
                            }
                        },
                    } );
                    return;
                }

                accept();
            } ).catch( function() {
                rejectPictogramFile( input, "Impossibile leggere il file." );
            } );
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