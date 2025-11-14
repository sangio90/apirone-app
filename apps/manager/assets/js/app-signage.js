AP.namespace( "signage" );

Object.assign( AP.signage.fields, {
    modalRoot: $( "#signage-modal" )
} );

$( document ).ready( function() {
    if ( AP.signage.fields.modalRoot.length ) {
        AP.signage.modal.init();
    }
} );

AP.signage.modal = ( function() {
    var pub = {};
    function generateUUID() {
        return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace( /[xy]/g, function( c ) {
            var r = Math.random() * 16 | 0; var v = c === "x" ? r : ( r & 0x3 | 0x8 );
            return v.toString( 16 );
        } );
    }
    var defaultDetailForm = {
        data: {
            id: "",
            quotationItem: {
                id: "",
                quantity: 1,
                price: 0,
                product: {
                    finish: {
                        id: ""
                    },
                    items: new kendo.data.DataSource(),
                },
                quotationZone: {
                    id: ""
                },
                signageConfigItem: {
                    id: "",
                },
                signageRows: new kendo.data.DataSource(),
            },
            signageConfig: {
                catalogBundle: {
                    category: {
                        id: ""
                    },
                    line: {
                        id: ""
                    },
                    model: {
                        id: ""
                    },
                },
                font: {
                    id: ""
                }
            },
            status: {
                id: "ACT",
            }
        },
        statuses: AP.page.statuses,
        title: "Carica segnaletica",
        canSave: false,
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,
        categories: new kendo.data.DataSource(),
        lines: new kendo.data.DataSource(),
        models: new kendo.data.DataSource(),
        finishes: new kendo.data.DataSource(),
        signageConfigs: new kendo.data.DataSource(),
        fonts: new kendo.data.DataSource(),
        fontSizes: new kendo.data.DataSource(),
        signageImages: new kendo.data.DataSource(),
        backgroundImage: {},
        maxRows: 0,
        modelConfig: {
            height: null,
            width: null
        },

        pictogramNames: [
            "<dx>",
            "<giu>",
            "<lift>",
            "<man>",
            "<pmr>",
            "<su>",
            "<sx>",
            "<wom>"
        ],

        checkCanSave: function() {
            var vm = viewModel;
            if (
                vm.get( "detailForm.data.quotationItem.quantity" ) > 0 &&
                vm.get( "detailForm.data.quotationItem.product.finish.id" ) != "" &&
                vm.get( "detailForm.data.quotationItem.signageConfigItem.id" ) != "" &&
                vm.get( "detailForm.data.signageConfig.catalogBundle.category.id" ) != "" &&
                vm.get( "detailForm.data.signageConfig.catalogBundle.line.id" ) != "" &&
                vm.get( "detailForm.data.signageConfig.catalogBundle.model.id" ) != "" &&
                vm.get( "detailForm.data.signageConfig.font.id" ) != ""
            ) {
                viewModel.set( "canSave", true );
            } else {
                viewModel.set( "canSave", false );
            }
        },

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
            $( "#signangeProductCategory" ).prop( "disabled", false );
            $( "#signageRow" ).prop( "disabled", false );
            $( "#signageModel" ).prop( "disabled", false );
            $( "#signageFinish" ).prop( "disabled", false );
            $( "#signageFont" ).prop( "disabled", false );
            $( "#product-items" ).empty();
        },

        parsedPictograms: function() {
            return this.pictogramNames.map( p => {
                const name = p.replace( /[<>]/g, "" );
                return {
                    label: name,
                    image: `<img src="/assets/main/pictograms/Arial/${name}.png" alt="${name}" class="pictogram px-2">`
                };
            } );
        },
        pictogramHelper: false,

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        getSignageConfig: function() {
            const fontId = viewModel.get( "detailForm.data.signageConfig.font.id" );
            if ( fontId ) {
                for ( var signageConfig of viewModel.get( "signageConfigs" ).data() ) {
                    if ( signageConfig.font && signageConfig.font.id == fontId ) {
                        return signageConfig;
                    }
                }
            }
        },

        getSignageConfigItems: function() {
            if ( viewModel.getSignageConfig() ) {
                var items = viewModel.getSignageConfig().items.map( item => ( {
                    ...item,
                    sizeName: item.size.name
                } ) );
                items.unshift( { id: "", sizeName: "-- Dimensione" } );
                return items;
            }

            return [];
        },

        addSignageRow: function() {
            var ds = viewModel.get( "detailForm.data.quotationItem.signageRows" );
            if ( ds && ds.data().length < viewModel.get( "maxRows" ) ) {
                var defaultSignageRow = {
                    id: generateUUID(),
                    textAlign: "center",
                    content: "",
                    charCount: 0,
                    orderby: 0,
                    newRow: true
                };
                ds.add( defaultSignageRow );

                ds.data().forEach( function( row, i ) {
                    row.set( "index", i + 1 );
                } );
            }

            this.setSelectedTextAlignIcon();

            return false;
        },

        parseLines: function( e ) {
            if ( viewModel.get( "detailForm.data.quotationItem.signageConfigItem.size.id" ) != "" ) {
                viewModel.set( "maxRows", viewModel.get( "detailForm.data.quotationItem.signageConfigItem.rowCount" ) );
                if ( viewModel.get( "detailForm.data.quotationItem.signageRows" ).data().length > viewModel.get( "maxRows" ) ) {
                    bootbox.confirm( {
                        title: "Cancellazione righe",
                        message: "Cambiando la dimensione del font cambierà la quantità di righe che puoi inserire nella segnaletica. Le righe in eccesso verranno eliminate, Vuoi procedere?",
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
                                const exceeded = viewModel.get( "detailForm.data.quotationItem.signageRows" ).data().slice( viewModel.get( "maxRows" ) );
                                const promises = exceeded.map( signageRow => {
                                    return new Promise( resolve => {
                                        setTimeout( function() {
                                            NM.util.ajax( {
                                                method: "DELETE",
                                                url: "/manager/ajax/quotation-items/signagerow",
                                                data: { id: signageRow.id },
                                                callback: {
                                                    done: function( xhr ) {
                                                        if ( xhr.status == "ERROR" ) {
                                                            AP.widget.notify( "error", "Errore nella cancellazione della Riga Segnaletica." );
                                                        }
                                                        if ( xhr.status == "SUCCESS" ) {
                                                            AP.widget.notify( "success", "Riga Segnaletica eliminata correttamente." );
                                                            const ds = viewModel.get( "detailForm.data.quotationItem.signageRows" );
                                                            const row = ds.view().find( r => r.id === signageRow.id );
                                                            if ( row ) {
                                                                ds.remove( row );
                                                            }
                                                            if ( ds ) {
                                                                ds.data().forEach( ( row, i ) => {
                                                                    row.set( "index", i + 1 );
                                                                } );
                                                            }
                                                        }
                                                        resolve();
                                                    }
                                                }
                                            } );
                                        }, 200 );
                                    } );
                                } );

                                Promise.all( promises ).then( () => {
                                    viewModel.save();
                                } );
                            }
                        },
                    } );
                }
                $( "#signageFont" ).prop( "disabled", true );
            } else {
                $( "#signageFont" ).prop( "disabled", false );
            }
            viewModel.get( "detailForm.data.quotationItem.signageRows" ).data().forEach( signageRow => {
                this.parsedLineContent( signageRow.content, signageRow.id );
                viewModel.updateCharCounter( {
                    currentTarget: document.getElementById( signageRow.uid + "_contentInput" )
                } );
            } );
            this.checkCanSave();
            NM.storage.set( "signage.signageConfigId", viewModel.get( "detailForm.data.quotationItem.signageConfigItem.id" ) );
            NM.storage.set( "signage.signageConfigRowCount", viewModel.get( "detailForm.data.quotationItem.signageConfigItem.rowCount" ) );
        },

        parsedLineContent: function( valore, id ) {
            const contentSpanPreview = $( "#content_span_preview_" + id );
            if ( !contentSpanPreview.length ) { return false; }

            const pictogramNames = viewModel.get( "pictogramNames" ) || []; // es. ["<man>", "<dx>", ...]
            const signageConfig = viewModel.getSignageConfig();
            if ( !signageConfig ) { return false; }

            const signageConfigItem = signageConfig.items.filter( function( config ) {
                return config.id == viewModel.get( "detailForm.data.quotationItem.signageConfigItem.id" );
            } )[0];

            if (
                viewModel.get( "detailForm.data.quotationItem.signageConfigItem.size.id" )
            ) {
                signageConfigItem.size = viewModel.get( "detailForm.data.quotationItem.signageConfigItem.size" );
            }
            const fontFamily = signageConfig.font && signageConfig.font.family ? signageConfig.font.family : "";
            const heightPx = signageConfigItem && signageConfigItem.size?.name ? signageConfigItem.size.name : 16;

            // costruisco la regex solo con i nomi interni dei pictogram (senza <>), escapati
            const innerNames = pictogramNames.map( n => n.replace( /[<>]/g, "" ) );
            const escapedNames = innerNames.map( this.escapeRegExp );
            const pictogramRegex = escapedNames.length ? new RegExp( "<(" + escapedNames.join( "|" ) + ")>", "g" ) : /$^/;

            // scorro il testo e costruisco parti: testo escapato oppure <img>
            const parts = [];
            let lastIndex = 0;
            let match;
            while ( ( match = pictogramRegex.exec( valore ) ) !== null ) {
                if ( match.index > lastIndex ) {
                    parts.push( this.escapeHtml( valore.substring( lastIndex, match.index ) ) );
                }

                const pictogramName = match[1]; // es. "man"
                const imgHtml =
                    // TODO: usare il font selezionato quando avremo i pictogram in tutti i font,
                    //      creare una mappa fontFamily -> esistenza pictogram
                    // "<img src=\"/assets/main/pictograms/" + fontFamily + "/" + pictogramName + ".png\" " +
                    "<img src=\"/assets/main/pictograms/Arial/" + pictogramName + ".png\" " +
                    "alt=\"" + pictogramName + "\" " +
                    "style=\"height: " + heightPx + "px;\" " +
                    "class=\"pictogram px-2\">";
                parts.push( imgHtml );

                lastIndex = pictogramRegex.lastIndex;
            }

            // resto finale (escapato)
            if ( lastIndex < valore.length ) {
                parts.push( this.escapeHtml( valore.substring( lastIndex ) ) );
            }

            contentSpanPreview.css( {
                "font-family": fontFamily,
                "font-size": heightPx + "px"
            } );

            contentSpanPreview.html( parts.join( "" ) );

            return false;
        },

        getSignageConfigItemSize: function() {
            return viewModel.get( "detailForm.data.quotationItem.signageConfigItem.size" );
        },

        escapeHtml: function( text ) {
            if ( text == null ) { return ""; }
            return String( text ).replace( /[&<>"']/g, function( m ) {
                return { "&":"&amp;", "<":"&lt;", ">":"&gt;", "\"":"&quot;", "'":"&#39;" }[m];
            } );
        },

        escapeRegExp: function( string ) {
            return String( string ).replace( /[.*+?^${}()|[\]\\]/g, "\\$&" );
        },

        extractAllOccurrences: function( haystack, needles ) {
            // Escapo i caratteri speciali per ciascun needle
            const escaped = needles.map( n => n.replace( /[.*+?^${}()|[\]\\]/g, "\\$&" ) );
            const regex = new RegExp( escaped.join( "|" ), "g" );

            // matchAll ritorna tutti i match nell'ordine
            const matches = [ ...haystack.matchAll( regex ) ].map( m => m[0] );

            return matches;
        },

        countPictogramsTotals: function( haystack, needles ) {
            let totalOccurrences = 0;
            let totalChars = 0;

            needles.forEach( needle => {
                // Escapo i caratteri speciali per sicurezza
                const regex = new RegExp( needle.replace( /[.*+?^${}()|[\]\\]/g, "\\$&" ), "g" );
                const matches = haystack.match( regex );
                const count = matches ? matches.length : 0;

                totalOccurrences += count;
                totalChars += count * needle.length;
            } );

            return { totalOccurrences, totalChars };
        },

        updateCharCounter: function( e ) {
            const signageConfig = viewModel.getSignageConfig();
            let charCount = e.currentTarget.value.length;
            const realContent = e.currentTarget.value;
            const pictogramNames = viewModel.get( "pictogramNames" );
            let content = e.currentTarget.value;
            const usedPictos = [];

            pictogramNames.forEach( pictogram => {
                let position = realContent.indexOf( pictogram );
                while ( position !== -1 ) {
                    usedPictos[position] = pictogram;
                    position = realContent.indexOf( pictogram, position + 1 );
                    content = content.replace( pictogram, "#" );
                }
            } );

            charCount = content.length;
            const signageConfigItem = signageConfig.items.filter( function( config ) {
                return config.id == viewModel.get( "detailForm.data.quotationItem.signageConfigItem.id" );
            } )[0];

            if ( charCount >= signageConfigItem.charCount && !this.hasUnclosedPictogram( realContent ) ) {
                content = content.substring( 0, signageConfigItem.charCount );
                charCount = signageConfigItem.charCount;
            }

            usedPictos.forEach( ( value, index ) => {
                if ( content[index] && content[index] == "#" ) {
                    content = content.replace( "#", value );
                }
            } );

            const uid = e.currentTarget.dataset.uid;
            const signageRow = viewModel.get( "detailForm.data.quotationItem.signageRows" ).getByUid( uid );

            signageRow.set( "content", content );
            e.currentTarget.value = content;
            signageRow.set( "charCount", charCount );

            $( "#" + uid + "_charCounter" ).html( charCount + "/" + signageConfigItem.charCount );

            this.parsedLineContent( content, signageRow.id );
            this.setSelectedTextAlignIcon();

            return false;
        },

        hasUnclosedPictogram: function( str ) {
            const lastOpen = str.lastIndexOf( "<" );
            const lastClose = str.lastIndexOf( ">" );
            return lastOpen > lastClose;
        },

        togglePictogramHelper: function( e ) {
            const helperModal = $( "#pictogram-helper-modal" );

            if ( helperModal.hasClass( "show" ) ) {
                helperModal.modal( "hide" );
            } else {
                helperModal.modal( "show" );
            }
        },

        setSelectedTextAlignIcon: function() {
            var rows = $( "#signage-rows-container" ).find( ".signage-row" );
            rows.each( function( index, row ) {
                var textAlign = viewModel.get( "detailForm.data.quotationItem.signageRows" ).data()[index].textAlign;
                var icon = $( row ).find( ".fa-align-" + textAlign )[0];
                $( icon ).removeClass( "selected-text-align-not" );
                $( icon ).addClass( "selected-text-align" );
            } );
        },

        removeSignageRow: function( e ) {
            if ( e.data.id != "" ) {
                bootbox.confirm( {
                    title: "Conferma eliminazione",
                    message: "Sei sicuro di voler cancellare questa riga della segnaletica?",
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
                            NM.util.ajax( {
                                method: "DELETE",
                                url: "/manager/ajax/quotation-items/signagerow",
                                data: { id: e.data.id },
                                callback: {
                                    done: function( xhr ) {
                                        if( xhr.status == "ERROR" ) {
                                            AP.widget.notify( "error", "Errore nella cancellazione della Riga Segnaletica." );
                                        }
                                        if ( xhr.status == "SUCCESS" ) {
                                            AP.widget.notify( "success", "Riga Segnaletica eliminata correttamente." );
                                            const ds = viewModel.get( "detailForm.data.quotationItem.signageRows" );
                                            const row = ds.view().find( r => r.id === e.data.id );
                                            isNewRow = row.hasOwnProperty( "newRow" ) ? row.newRow : null;
                                            if ( row ) {
                                                ds.remove( row );
                                            }
                                            if ( ds ) {
                                                ds.data().forEach( ( row, i ) => {
                                                    row.set( "index", i + 1 );
                                                } );
                                            }
                                            if ( !isNewRow ) {
                                                viewModel.save();
                                            }
                                        }
                                    } }
                            } );
                        }
                    },
                } );
            } else {
                const uid = e.data.uid;
                const ds = viewModel.get( "detailForm.data.quotationItem.signageRows" );
                const row = ds.getByUid( uid );
                if ( row ) {
                    ds.remove( row );
                }
                return false;
            }
        },

        setTextAlign: function( e ) {
            var ds = viewModel.get( "detailForm.data.quotationItem.signageRows" );
            var signageRow = ds.data().find( row => row.uid === e.data.uid );
            if ( signageRow ) {
                signageRow.set( "textAlign", $( e.currentTarget ).data( "value" ) );
            }
            $( e.currentTarget ).addClass( "selected-text-align" ).siblings()
                .removeClass( "selected-text-align" )
                .addClass( "selected-text-align-not" );
        },

        loadLines: function( event ) {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/lines/" + viewModel.get( "detailForm.data.signageConfig.catalogBundle.category.id" ),
                callback: {
                    done: function( xhr ) {
                        xhr.data.unshift( { id: "", name: "-- Seleziona la Linea" } );
                        viewModel.get( "lines" ).data( xhr.data );
                    },
                },
            } );
            this.checkCanSave();
            NM.storage.set( "signage.categoryId", viewModel.get( "detailForm.data.signageConfig.catalogBundle.category.id" ) );
        },

        loadModels: function( event ) {
            if ( viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.id" ) != "" ) {
                $( "#signangeProductCategory" ).prop( "disabled", true );
                if ( viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.code" ) != "LET00" ) {
                    $( "#signage-preview-background" ).css( {
                        width: "500px",
                        height: "500px"
                    } );
                } else {
                    $( "#signage-preview-background" ).css( {
                        width: "500px",
                        height: null
                    } );
                }
            } else {
                $( "#signangeProductCategory" ).prop( "disabled", false );
            }
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/models/" + viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.id" ),
                callback: {
                    done: function( xhr ) {
                        xhr.data.unshift( { id: "", name: "-- Seleziona il Modello" } );
                        viewModel.get( "models" ).data( xhr.data );
                    },
                },
            } );
            this.checkCanSave();
            NM.storage.set( "signage.lineId", viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.id" ) );
        },

        loadFinishes: function( event ) {
            if ( viewModel.get( "detailForm.data.signageConfig.catalogBundle.model.id" ) != "" ) {
                $( "#signageRow" ).prop( "disabled", true );
                NM.util.ajax( {
                    method: "GET",
                    url: "/manager/ajax/quotations/finishes/" + viewModel.get( "detailForm.data.signageConfig.catalogBundle.category.id" ) + "/" + viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.id" ),
                    callback: {
                        done: function( xhr ) {
                            xhr.data.unshift( { id: "", name: "-- Seleziona la Finitura" } );
                            viewModel.get( "finishes" ).data( xhr.data );
                            NM.util.ajax( {
                                method: "GET",
                                url: "/manager/ajax/model-config/get-by-params?categoryId=" +
                                    viewModel.get( "detailForm.data.signageConfig.catalogBundle.category.id" ) +
                                    "&lineId=" +
                                    viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.id" ) +
                                    "&modelId=" +
                                    viewModel.get( "detailForm.data.signageConfig.catalogBundle.model.id" ),
                                callback: {
                                    done: function( xhr ) {
                                        if ( xhr.data && xhr.data.modelConfig ) {
                                            var modelConfig = {
                                                width: xhr.data.modelConfig.width,
                                                height: xhr.data.modelConfig.height,
                                            };
                                            viewModel.set( "modelConfig", modelConfig );
                                        } else {
                                            viewModel.set( "modelConfig", { width: null, height: null } );
                                        }

                                        if ( viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.code" ) != "LET00" ) {
                                            $( "#signage-preview-container" ).css( {
                                                width: viewModel.get( "modelConfig.width" ) + "px",
                                                height: viewModel.get( "modelConfig.height" ) + "px"
                                            } );
                                        } else {
                                            $( "#signage-preview-container" ).css( {
                                                width: "500px",
                                                height: "500px"
                                            } );
                                        }
                                    }
                                }
                            } );
                        },
                    },
                } );
            } else {
                $( "#signageRow" ).prop( "disabled", false );
            }
            this.checkCanSave();
            NM.storage.set( "signage.modelId", viewModel.get( "detailForm.data.signageConfig.catalogBundle.model.id" ) );
        },

        loadSignageConfigs: function( event ) {
            if ( viewModel.get( "detailForm.data.quotationItem.product.finish.id" ) != "" ) {
                $( "#signageModel" ).prop( "disabled", true );
            } else {
                $( "#signageModel" ).prop( "disabled", false );
            }
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/signage-configs?categoryId="
                    + viewModel.get( "detailForm.data.signageConfig.catalogBundle.category.id" )
                    + "&lineId="
                    + viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.id" )
                    + "&modelId="
                    + viewModel.get( "detailForm.data.signageConfig.catalogBundle.model.id" ),
                callback: {
                    done: function( xhr ) {
                        const fonts = [];

                        for ( var font of xhr.data ) {
                            fonts.push( font.font );
                        }
                        fonts.unshift( { id: "", name: "-- Seleziona il Font" } );
                        viewModel.get( "fonts" ).data( fonts );
                        xhr.data.unshift( { id: "", name: "" } );
                        viewModel.get( "signageConfigs" ).data( xhr.data );

                        if ( fonts.length === 1 ) {
                            viewModel.set( "detailForm.data.signageConfig.font.id", fonts[0].id );
                            viewModel.get( "fontSizes" ).data( xhr.data[0].items );
                        }
                        if ( viewModel.get( "detailForm.data.quotationItem.product.finish.id" ) != "" ) {
                            NM.util.ajax( {
                                method: "GET",
                                url: "/manager/ajax/products/get-id-and-file-by-params?categoryId=" +
                                viewModel.get( "detailForm.data.signageConfig.catalogBundle.category.id" ) +
                                "&lineId=" +
                                viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.id" ) +
                                "&modelId=" +
                                viewModel.get( "detailForm.data.signageConfig.catalogBundle.model.id" ) +
                                "&finishId=" +
                                viewModel.get( "detailForm.data.quotationItem.product.finish.id" ),
                                callback: {
                                    done: function( xhr ) {
                                        if ( xhr.data.productId ) {
                                            viewModel.set( "detailForm.data.quotationItem.product.id", xhr.data.productId );
                                        }
                                        if ( xhr.data.file ) {
                                            viewModel.set( "backgroundImage", xhr.data.file );
                                            viewModel.set( "backgroundImage.url", "url('" + xhr.data.file.uri + "')" );
                                        } else {
                                            viewModel.set( "backgroundImage.url", "url()" );
                                        }
                                    },
                                },
                            } );
                        }
                    },
                },
            } );
            this.checkCanSave();
            if ( viewModel.get( "detailForm.data.quotationItem.product.finish.id" ) != NM.storage.get( "signage.finishId" ) ) {
                NM.storage.delete( "signage.product.items" );
            }
            NM.storage.set( "signage.finishId", viewModel.get( "detailForm.data.quotationItem.product.finish.id" ) );
        },

        loadFontSizes: function() {
            if ( viewModel.get( "detailForm.data.signageConfig.font.id" ) != "" ) {
                $( "#signageFinish" ).prop( "disabled", true );
            } else {
                $( "#signageFinish" ).prop( "disabled", false );
            }
            var signageConfig = viewModel.getSignageConfig();
            if ( signageConfig ) {
                this.firstLoadProductItems();
                // const exists = viewModel.getSignageConfig().items.some( item => item.id === "" );
                // viewModel.getSignageConfig().items.forEach( function( item ) {
                //     fontSizes.push( item.size );
                // } );
                // viewModel.get( "fontSizes" ).data( fontSizes );
                viewModel.set( "detailForm.data.signageConfig.items", viewModel.getSignageConfigItems() );
                $( "#signageFontSize" ).select( {
                    dataSource: viewModel.get( "detailForm.data.signageConfig.items" ),
                    value: viewModel.get( "detailForm.data.quotationItem.signageConfigItem" ),
                    dataTextField: "sizeName",
                    dataValueField: "id",
                    change: function() {
                        viewModel.parseLines();
                    }
                } );
                if ( viewModel.get( "detailForm.data.signageConfig.items" ).length == 2 ) {
                    viewModel.set( "detailForm.data.quotationItem.signageConfigItem", viewModel.get( "detailForm.data.signageConfig.items" )[1] );
                    this.parseLines();
                }
            }
            this.checkCanSave();
            NM.storage.set( "signage.fontId", viewModel.get( "detailForm.data.signageConfig.font.id" ) );
        },

        firstLoadProductItems: async function() {
            const quotationItemId = viewModel.get( "detailForm.data.quotationItem.id" );
            const productId = viewModel.get( "detailForm.data.quotationItem.product.id" );

            // Chiamata AJAX iniziale per ottenere tutti i product items
            await NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/product-items?productId=" + productId,
                callback: {
                    done: function( xhr ) {
                        if ( xhr.data.length > 0 ) {
                            if ( quotationItemId != "" ) {
                                viewModel.set( "detailForm.data.quotationItem.product.items", new kendo.data.DataSource() );
                            }
                            productItems = viewModel.get( "detailForm.data.quotationItem.product.items" );
                            attributeArray = productItems.data();
                            // settiamo nel viewModel tutte le select di level 0 e le popoliamo con tutte le options
                            xhr.data.forEach( item => {
                                const existing = attributeArray.find( d => d.attribute_id === item.attribute.id );
                                if ( existing ) {
                                    if ( !existing.values.find( v => v.product_item_id === item.id ) ) {
                                        existing.values.push( {
                                            attributeValue: item.attributeValue,
                                            product_item_id: item.id,
                                            parent_attribute_id: null,
                                            parent_item_id: null,
                                            level: 0,
                                            selected: false
                                        } );
                                        productItems.trigger( "change" );
                                    }
                                } else {
                                    const parsedData = {
                                        attribute_id: item.attribute.id,
                                        attribute_name: item.attribute.name,
                                        parent_attribute_id: null,
                                        parent_item_id: null,
                                        level: 0,
                                        values: [
                                            {
                                                attributeValue: item.attributeValue,
                                                product_item_id: item.id,
                                                selected: false
                                            }
                                        ]
                                    };
                                    productItems.add( parsedData );
                                }
                            } );
                            // Se è un nuovo quotation item, precompilo tutte le select di primo livello con il primo valore (come richiesto da loro)
                            if ( quotationItemId == "" ) {
                                productItems.data().forEach( d => {
                                    d.values[0].selected = true;
                                    viewModel.loadProductItems( d.values[0].product_item_id, d.attribute_id );
                                } );
                            }
                            viewModel.renderProductItems();
                        }
                    }
                }
            } ).then( async function() {
                // Se ci sono quotation items pre-selezionati, li carichiamo
                if ( quotationItemId != "" ) {
                    await NM.util.ajax( {
                        method: "GET",
                        url: "/manager/ajax/quotation-items/" + quotationItemId + "/product-items",
                        callback: {
                            done: async function( xhr ) {
                                xhr.data.sort( ( a, b ) => a.productItem.orderby - b.productItem.orderby );
                                if ( xhr.data.length > 0 ) {
                                    for ( const qipi of xhr.data ) {
                                        const select = $( `select[data-attribute-id="${qipi.productItem.attribute.id}"]` );
                                        if ( select.length > 0 ) {
                                            select.val( qipi.productItem.id );
                                            // Carichiamo eventuali figli ricorsivamente
                                            await viewModel.loadProductItems( qipi.productItem.id, qipi.productItem.attribute.id );
                                        }
                                    }
                                }
                            }
                        }
                    } );
                }
            } );
        },

        loadProductItems: function( originId, attributeId ) {
            return new Promise( ( resolve, reject ) => {
                const productId = viewModel.get( "detailForm.data.quotationItem.product.id" );
                const productItems = viewModel.get( "detailForm.data.quotationItem.product.items" );
                const attributeArray = productItems.data();
                originId = originId || "";

                let url = "/manager/ajax/product-items?productId=" + productId;
                if ( originId ) {
                    url += "&originId=" + originId;
                }

                // Deselezionamento: originId vuoto
                if ( originId === "" ) {
                    let actualIndex = null;
                    for ( let i = attributeArray.length - 1; i >= 0; i-- ) {
                        if ( attributeArray[i].attribute_id === attributeId ) {
                            actualIndex = i;
                            attributeArray[i].values.forEach( attrValue => attrValue.selected = false );
                        }
                    }
                    // Rimuovo attributi figli
                    const i = actualIndex + 1;
                    while ( i < attributeArray.length ) {
                        if ( attributeArray[i].level > attributeArray[actualIndex].level ) {
                            productItems.remove( attributeArray[i] );
                        } else {
                            break;
                        }
                    }
                    viewModel.renderProductItems();
                    resolve();
                    return;
                }

                // Selezionamento: originId valorizzato
                NM.util.ajax( {
                    method: "GET",
                    url: url,
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.data.length > 0 ) {
                                let attribute = null;
                                let toInsert = false;
                                let parentIndex = -1;

                                // Trovo l'indice dell'attributo selezionato
                                attributeArray.forEach( ( d, idx ) => {
                                    if ( d.attribute_id == attributeId ) { parentIndex = idx; }
                                } );

                                // Rimuovo eventuali attributi figli
                                const i = parentIndex + 1;
                                while ( i < attributeArray.length ) {
                                    if ( attributeArray[i].level > attributeArray[parentIndex].level ) {
                                        productItems.remove( attributeArray[i] );
                                    } else {
                                        break;
                                    }
                                }

                                // Creo nuovo attributo se necessario
                                if ( !attribute ) {
                                    attribute = {
                                        attribute_id: xhr.data[0].attribute.id,
                                        attribute_name: xhr.data[0].attribute.name,
                                        parent_attribute_id: attributeId,
                                        parent_item_id: originId,
                                        level: attributeArray[parentIndex].level + 1,
                                        values: []
                                    };
                                    toInsert = true;
                                }

                                // Imposto selected sul parent
                                if ( parentIndex !== -1 ) {
                                    const parent = productItems.at( parentIndex );
                                    parent.get( "values" ).forEach( v => {
                                        v.selected = v.product_item_id == originId;
                                    } );
                                }

                                // Popolo i valori del nuovo attributo
                                xhr.data.forEach( function( item ) {
                                    attribute.values.push( {
                                        attributeValue: item.attributeValue,
                                        product_item_id: item.id,
                                        selected: false
                                    } );
                                } );

                                // Inserisco attributo se nuovo
                                if ( toInsert ) {
                                    productItems.insert( parentIndex + 1, attribute );
                                }
                            } else {
                                // Se non ci sono figli, setto selected sul parent
                                let parentIndex = -1;
                                attributeArray.forEach( ( d, idx ) => {
                                    if ( d.attribute_id == attributeId ) { parentIndex = idx; }
                                    if ( d.parent_item_id ) {
                                        if ( attributeArray[idx - 1].values.filter( v => v.selected == false && v.product_item_id == d.parent_item_id ).length > 0 ) {
                                            productItems.remove( d );
                                        }
                                    }
                                } );
                                if ( parentIndex !== -1 ) {
                                    const parent = productItems.at( parentIndex );
                                    parent.get( "values" ).forEach( v => {
                                        v.selected = v.product_item_id == originId;
                                    } );
                                }

                                // aggiunto per cercare gli elementi dell'albero legati ad un parent non selezionato e rimuoverli
                                var elementsToRemove = [];
                                attributeArray.forEach( ( d, idx ) => {
                                    if ( d.parent_item_id ) {
                                        if ( attributeArray[idx - 1].values.filter( v => v.selected == false && v.product_item_id == d.parent_item_id ).length > 0 ) {
                                            elementsToRemove.push( idx );
                                        }
                                    }
                                } );
                                elementsToRemove.forEach( function( idx ) {
                                    productItems.remove( productItems.at( idx ) );
                                } );
                            }

                            viewModel.renderProductItems();
                            resolve();
                        },
                        fail: function( err ) {
                            reject( err );
                        }
                    }
                } );
            } );
        },

        renderProductItems: function() {
            const container = $( "#product-items" );
            container.empty();
            const productItems = viewModel.get( "detailForm.data.quotationItem.product.items" );
            attributeArray = productItems.data();
            attributeArray.forEach( function( item ) {
                const attrName = item.attribute_name;
                const values = item.values;

                const subContainer = $( "<div>" );
                subContainer.attr( "id", "attribute-container-" + item.attribute_id );
                container.append( subContainer );

                const label = $( "<label>" );
                label.addClass( "mb-1" );
                label.css( "margin-left", ( 1.5 * item.level ) + "rem" );
                label.text( attrName );
                subContainer.append( label );

                const select = $( "<select>" ).addClass( "form-control me-3 mb-2" ).on( "change", function() {
                    const selectedId = $( this ).val();
                    const attributeId = $( this ).data( "attribute-id" );
                    viewModel.loadProductItems( selectedId, attributeId );
                } );
                select.attr( "data-attribute-id", item.attribute_id );

                if ( item.level > 0 ) {
                    select.css( "margin-left", ( 1.5 * item.level ) + "rem" );
                    select.css( "width", `calc(100% - ${1.5 * item.level}rem)` );
                }

                const emptyOption = $( "<option>" ).val( "" ).html( "-- Seleziona valore attributo" );
                select.append( emptyOption );

                values.forEach( function( attrValue ) {
                    const option = $( "<option>" )
                        .val( attrValue.product_item_id )
                        .html( `<b>${attrName}</b> ${attrValue.attributeValue.rawValue.name}` );
                    select.append( option );
                } );

                // Imposto la option selezionata
                const selectedOption = values.find( attrValue => attrValue.selected === true );
                if ( selectedOption ) {
                    select.val( selectedOption.product_item_id );
                }

                subContainer.append( select );
            } );
        },

        unsetSelects: function( data ) {
            data.forEach( function( element ) {
                viewModel.set( "detailForm." + element, viewModel.get( "defaultDetailForm." + element ) );
            } );
        },

        save: function( event ) {
            var quotationId = AP.page.quotation.id;
            const parsedData = viewModel.get( "detailForm.data" );
            const signageRows = parsedData.quotationItem.signageRows.data();
            var exceedinRows = 0;
            signageRows.forEach( function( row ) {
                if ( row.charCount > parsedData.quotationItem.signageConfigItem.charCount ) {
                    exceedinRows = exceedinRows + 1;
                }
            } );
            if ( exceedinRows > 0 ) {
                return AP.widget.notify( "error", "C'è almeno una riga con più caratteri di quelli consentiti." );
            }
            parsedData.quotationId = quotationId;
            parsedData.type = "signage";
            var preview = $( "#signage-preview-background" )[0];

            html2canvas( preview, { useCORS: true } ).then( function( canvas ) {
                const imgData = canvas.toDataURL( "image/png" ).replace( /^data:image\/png;base64,/, "" );
                parsedData.imageBase64 = imgData;
                parsedData.mode = "segnaletiche";

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotation-items",
                    data: JSON.stringify( parsedData ),
                    callback: {
                        done: function( xhr ) {
                            if( xhr.status == "ERRORE" ) {
                                if ( xhr.data && xhr.data.error ) {
                                    AP.widget.notify( "error", xhr.data.error );
                                } else {
                                    AP.widget.notify( "error", "Errore nel salvataggio della segnaletica." );
                                }
                            }
                            if ( xhr.status == "SUCCESS" ) {
                                AP.widget.notify( "success", "Segnaletica salvata nel preventivo." );
                                viewModel.set( "detailForm", defaultDetailForm );
                                setTimeout( () => window.location.reload(), 1000 );
                            }
                        }
                    }
                } );
            } );

            return false;
        },

        visibleUpperClearButton: function() {
            const id = viewModel.get( "detailForm.data.quotationItem.id" );
            return id == "";
        },

        visibleLowerClearButton: function() {
            const signageConfigId = this.get( "detailForm.data.quotationItem.signageConfigItem.id" );
            const id = viewModel.get( "detailForm.data.quotationItem.id" );
            return signageConfigId == "" && id == "";
        },

        clearFilters: function() {
            viewModel.resetForm();
            NM.storage.delete( "signage.categoryId" );
            NM.storage.delete( "signage.lineId" );
            NM.storage.delete( "signage.modelId" );
            NM.storage.delete( "signage.finishId" );
            NM.storage.delete( "signage.fontId" );
            NM.storage.delete( "signage.signageConfigId" );
            NM.storage.delete( "signage.product.items" );
            this.checkCanSave();
        },

        handleParamsUnset: function( param ) {
            if ( param === "category" ) {
                setTimeout( function() {
                    if ( $( "#signageFontSize" ).val() !== "" ) {
                        $( "#signageFontSize" ).val( "" );
                        $( "#signageFontSize" ).trigger( "change" );
                    }
                    setTimeout( function() {
                        if ( $( "#signageFont" ).val() !== "" ) {
                            $( "#signageFont" ).val( "" );
                            $( "#signageFont" ).trigger( "change" );
                        }
                        setTimeout( function() {
                            if ( $( "#signageFinish" ).val() !== "" ) {
                                $( "#signageFinish" ).val( "" );
                                $( "#signageFinish" ).trigger( "change" );
                            }
                            setTimeout( function() {
                                if ( $( "#signageModel" ).val() !== "" ) {
                                    $( "#signageModel" ).val( "" );
                                    $( "#signageModel" ).trigger( "change" );
                                }
                                setTimeout( function() {
                                    if ( $( "#signageRow" ).val() !== "" ) {
                                        $( "#signageRow" ).val( "" );
                                        $( "#signageRow" ).trigger( "change" );
                                    }
                                }, 100 );
                            }, 100 );
                        }, 100 );
                    }, 100 );
                }, 100 );
            }
            if ( param === "line" ) {
                setTimeout( function() {
                    if ( $( "#signageFontSize" ).val() !== "" ) {
                        $( "#signageFontSize" ).val( "" );
                        $( "#signageFontSize" ).trigger( "change" );
                    }
                    setTimeout( function() {
                        if ( $( "#signageFont" ).val() !== "" ) {
                            $( "#signageFont" ).val( "" );
                            $( "#signageFont" ).trigger( "change" );
                        }
                        setTimeout( function() {
                            if ( $( "#signageFinish" ).val() !== "" ) {
                                $( "#signageFinish" ).val( "" );
                                $( "#signageFinish" ).trigger( "change" );
                            }
                            setTimeout( function() {
                                if ( $( "#signageModel" ).val() !== "" ) {
                                    $( "#signageModel" ).val( "" );
                                    $( "#signageModel" ).trigger( "change" );
                                }
                            }, 100 );
                        }, 100 );
                    }, 100 );
                }, 100 );
            }
            if ( param === "model" ) {
                setTimeout( function() {
                    if ( $( "#signageFontSize" ).val() !== "" ) {
                        $( "#signageFontSize" ).val( "" );
                        $( "#signageFontSize" ).trigger( "change" );
                    }
                    setTimeout( function() {
                        if ( $( "#signageFont" ).val() !== "" ) {
                            $( "#signageFont" ).val( "" );
                            $( "#signageFont" ).trigger( "change" );
                        }
                        setTimeout( function() {
                            if ( $( "#signageFinish" ).val() !== "" ) {
                                $( "#signageFinish" ).val( "" );
                                $( "#signageFinish" ).trigger( "change" );
                            }
                        }, 100 );
                    }, 100 );
                }, 100 );
            }
            if ( param === "finish" ) {
                setTimeout( function() {
                    if ( $( "#signageFontSize" ).val() !== "" ) {
                        $( "#signageFontSize" ).val( "" );
                        $( "#signageFontSize" ).trigger( "change" );
                    }
                    setTimeout( function() {
                        if ( $( "#signageFont" ).val() !== "" ) {
                            $( "#signageFont" ).val( "" );
                            $( "#signageFont" ).trigger( "change" );
                        }
                    }, 100 );
                }, 100 );
            }
            if ( param === "font" ) {
                setTimeout( function() {
                    if ( $( "#signageFontSize" ).val() !== "" ) {
                        $( "#signageFontSize" ).val( "" );
                        $( "#signageFontSize" ).trigger( "change" );
                    }
                }, 100 );
            }
            this.checkCanSave();
        }
    } );

    pub.new = function( onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/categories?typeId=SEG",
            callback: {
                done: function( xhr ) {
                    if ( xhr.data.length > 0 ) {
                        xhr.data.unshift( { id: "", name: "-- Seleziona la Categoria" } );
                        viewModel.get( "categories" ).data( xhr.data );
                    }
                    NM.util.openModal( AP.signage.fields.modalRoot );
                }
            },
        } );
        viewModel.resetForm();
        viewModel.set( "detailForm.data.quotationItem.quotationZone", AP.quotationDetail.detail.config().zone );

        if ( NM.storage.get( "signage.categoryId" ) ) {
            viewModel.set( "detailForm.data.signageConfig.catalogBundle.category.id", NM.storage.get( "signage.categoryId" ) );
        }
        if ( NM.storage.get( "signage.lineId" ) ) {
            viewModel.set( "detailForm.data.signageConfig.catalogBundle.line.id", NM.storage.get( "signage.lineId" ) );
        }
        if ( NM.storage.get( "signage.modelId" ) ) {
            viewModel.set( "detailForm.data.signageConfig.catalogBundle.model.id", NM.storage.get( "signage.modelId" ) );
        }
        if ( NM.storage.get( "signage.finishId" ) ) {
            viewModel.set( "detailForm.data.quotationItem.product.finish.id", NM.storage.get( "signage.finishId" ) );
        }
        if ( NM.storage.get( "signage.fontId" ) ) {
            viewModel.set( "detailForm.data.signageConfig.font.id", NM.storage.get( "signage.fontId" ) );
        }
        if ( NM.storage.get( "signage.signageConfigId" ) ) {
            viewModel.set( "detailForm.data.quotationItem.signageConfigItem.id", NM.storage.get( "signage.signageConfigId" ) );
            viewModel.set( "detailForm.data.quotationItem.signageConfigItem.rowCount", NM.storage.get( "signage.signageConfigRowCount" ) );
        }

        viewModel.loadLines();
        setTimeout( function() {
            if ( NM.storage.get( "signage.lineId" ) ) {
                viewModel.loadModels();
                setTimeout( function() {
                    if ( NM.storage.get( "signage.modelId" ) ) {
                        viewModel.loadFinishes();
                        setTimeout( function() {
                            if ( NM.storage.get( "signage.finishId" ) ) {
                                viewModel.loadSignageConfigs();
                                setTimeout( function() {
                                    if ( NM.storage.get( "signage.fontId" ) ) {
                                        viewModel.loadFontSizes();
                                        setTimeout( function() {
                                            if ( NM.storage.get( "signage.signageConfigId" ) ) {
                                                setTimeout( function() {
                                                    viewModel.parseLines();
                                                }, 200 );
                                            }
                                        }, 200 );
                                    }
                                }, 200 );
                            }
                        }, 200 );
                    }
                }, 200 );
            }
        }, 200 );
    };

    pub.edit = function( { id, onSave } ) {
        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/categories?typeId=SEG",
            callback: {
                done: function( xhr ) {
                    xhr.data.unshift( { id: "", name: "" } );
                    viewModel.get( "categories" ).data( xhr.data );
                    NM.util.openModal( AP.signage.fields.modalRoot );
                },
            },
        } );

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotation-items/signage/" + id,
            callback: {
                done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {
                        var data = xhr.data;
                        var signageRowsArray = data.quotationItem.signageRows;
                        if ( data.quotationItem && Array.isArray( signageRowsArray ) ) {
                            data.quotationItem.signageRows = new kendo.data.DataSource( {
                                data: signageRowsArray.slice(),
                                schema: {
                                    model: {
                                        id: "id"
                                    }
                                }
                            } );
                        } else {
                            data.quotationItem.signageRows = new kendo.data.DataSource( {
                                data: [],
                                schema: { model: { id: "id" } }
                            } );
                        }
                        data.quotationItem.signageRows.read();
                        viewModel.set( "detailForm.data", data );
                        var ds = viewModel.get( "detailForm.data.quotationItem.signageRows" );
                        if ( ds && ds.data().length ) {
                            ds.data().forEach( function( row, i ) {
                                row.set( "index", i + 1 );
                            } );
                        }
                        viewModel.set( "detailForm.title", "Modifica segnaletica" );

                        viewModel.loadLines();

                        setTimeout( function() {
                            viewModel.loadModels();
                            setTimeout( function() {
                                viewModel.loadFinishes();
                                setTimeout( function() {
                                    viewModel.loadSignageConfigs();
                                    setTimeout( function() {
                                        viewModel.loadFontSizes();
                                        setTimeout( function() {
                                            setTimeout( function() {
                                                viewModel.parseLines();
                                                ds.data().forEach( row => {
                                                    viewModel.updateCharCounter( {
                                                        currentTarget: document.getElementById( row.uid + "_contentInput" )
                                                    } );
                                                } );
                                                NM.util.openModal( AP.signage.fields.modalRoot );
                                                viewModel.setSelectedTextAlignIcon();
                                            }, 200 );
                                        }, 200 );
                                    }, 200 );
                                }, 200 );
                            }, 200 );
                        }, 200 );
                    }
                },
            },
        } );

        renderQuotationItemTotals( id );
    };

    pub.init = function() {
        kendo.bind( AP.signage.fields.modalRoot, viewModel );
    };

    renderQuotationItemTotals = function( quotationItemId ) {
        NM.util.ajax( {
            method: "GET",
            url: `/manager/ajax/quotation-items/${quotationItemId}/total`,
            callback: {
                done: function( xhr ) {
                    if( xhr.data ) {
                        if ( !xhr.data.id || xhr.data.id != quotationItemId ) {
                            $( "#totalsFloatingTab" ).hide();
                        } else {
                            viewModel.set( "detailForm.data.totals", xhr.data );
                            var totals = viewModel.get( "detailForm.data.totals" );
                            if ( xhr.data ) {
                                const table = $( "#totalsFloatingTab" ).find( "table" )[0];
                                totals.products.forEach( function( row ) {
                                    $( table ).append( `
                                        <tr>
                                            <td>${row.id} - ${row.label}</td>
                                            <td>${row.amount.toLocaleString( "it-IT", { style: "currency", currency: "EUR" } )}</td>
                                        </tr>
                                    ` );
                                } );
                                $( table ).append(
                                    `<tr>
                                        <td>${totals.quantity.label}</td>
                                        <td>${totals.quantity.count}</td>
                                    </tr>
                                    <tr style="font-weight: bold">
                                        <td>${totals.total.label}</td>
                                        <td>${totals.total.amount.toLocaleString( "it-IT", { style: "currency", currency: "EUR" } )}</td>
                                    </tr>
                                    `
                                );
                            }
                            $( "#totalsFloatingTab" ).show();
                        }
                    }
                }
            }
        } );
    };

    return pub;
} () );
