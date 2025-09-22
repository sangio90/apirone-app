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
                    }
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

        addSignageRow: function() {
            var ds = viewModel.get( "detailForm.data.quotationItem.signageRows" );
            if ( ds && ds.data().length < 10 ) {
                var defaultSignageRow = {
                    id: generateUUID(),
                    textAlign: "center",
                    content: "",
                    charCount: 0,
                    orderby: 0
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
            viewModel.get( "detailForm.data.quotationItem.signageRows" ).data().forEach( signageRow => {
                this.parsedLineContent( signageRow.content, signageRow.id );
            } );
            this.checkCanSave();
        },

        parsedLineContent: function( valore, id ) {
            const contentSpanPreview = $( "#content_span_preview_" + id );

            if ( contentSpanPreview.length == 1 ) {
                const pictogramNames = viewModel.get( "pictogramNames" );
                const pictograms = this.extractAllOccurrences( valore, pictogramNames );
                const signageConfig = viewModel.getSignageConfig();
                const signageConfigItem = signageConfig.items.filter( function( config ) { return config.id == viewModel.get( "detailForm.data.quotationItem.signageConfigItem.id" ); } )[0];
                const fontFamily = signageConfig.font.family;
                pictograms.forEach( function( pictogram ) {
                    valore = valore.replace( pictogram,
                        "<img src=\"/assets/main/pictograms/" + fontFamily + "/" + pictogram.replace( /[<>]/g, "" ) + ".png\" alt=\"" + pictogram.replace( /[<>]/g, "" ) + "\" style=\"transform: scale(" + signageConfigItem.height / 100 + ");\" class=\"pictogram px-2\">"
                    );
                } );

                contentSpanPreview.css( {
                    "font-family": fontFamily,
                    "font-size": signageConfigItem.heightInPixel + "px"
                } );

                contentSpanPreview.html( valore );
            }

            return false;
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
            const signageConfigItem = signageConfig.items.filter( function( config ) { return config.id == viewModel.get( "detailForm.data.quotationItem.signageConfigItem.id" ); } )[0];

            if ( charCount >= signageConfigItem.charCount ) {
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
            signageRow.set( "charCount", charCount );

            $( "#" + uid + "_charCounter" ).html( charCount + "/" + signageConfigItem.charCount );

            this.parsedLineContent( content, signageRow.id );
            this.setSelectedTextAlignIcon();

            return false;
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
                                if ( row ) {
                                    ds.remove( row );
                                }
                                if ( ds ) {
                                    ds.data().forEach( ( row, i ) => {
                                        row.set( "index", i + 1 );
                                    } );
                                }
                                return false;
                            }
                        } }
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
                        xhr.data.unshift( { id: "", name: "" } );
                        viewModel.get( "lines" ).data( xhr.data );
                        NM.util.openModal( AP.signage.fields.modalRoot );
                    },
                },
            } );
            this.checkCanSave();
        },

        loadModels: function( event ) {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/models/" + viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.id" ),
                callback: {
                    done: function( xhr ) {
                        xhr.data.unshift( { id: "", name: "" } );
                        viewModel.get( "models" ).data( xhr.data );
                        NM.util.openModal( AP.signage.fields.modalRoot );
                    },
                },
            } );
            this.checkCanSave();
        },

        loadFinishes: function( event ) {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/finishes/" + viewModel.get( "detailForm.data.signageConfig.catalogBundle.category.id" ) + "/" + viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.id" ),
                callback: {
                    done: function( xhr ) {
                        xhr.data.unshift( { id: "", name: "" } );
                        viewModel.get( "finishes" ).data( xhr.data );
                        NM.util.openModal( AP.signage.fields.modalRoot );
                    },
                },
            } );
            this.checkCanSave();
        },

        loadSignageConfigs: function( event ) {
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
                        fonts.unshift( { id: "", name: "" } );
                        viewModel.get( "fonts" ).data( fonts );
                        xhr.data.unshift( { id: "", name: "" } );
                        viewModel.get( "signageConfigs" ).data( xhr.data );

                        if ( fonts.length === 1 ) {
                            viewModel.set( "detailForm.data.signageConfig.font.id", fonts[0].id );
                            viewModel.get( "fontSizes" ).data( xhr.data[0].items );
                        }

                        NM.util.openModal( AP.signage.fields.modalRoot );
                    },
                },
            } );
            this.checkCanSave();
        },

        loadFontSizes: function() {
            var signageConfig = viewModel.getSignageConfig();
            if ( signageConfig ) {
                const exists = viewModel.getSignageConfig().items.some( item => item.id === "" );
                if ( !exists ) {
                    viewModel.getSignageConfig().items.unshift( { id: "", height: "" } );
                }
                viewModel.get( "fontSizes" ).data( viewModel.getSignageConfig().items );
                if ( signageConfig.items.length == 2 ) {
                    viewModel.set( "detailForm.data.quotationItem.signageConfigItem", signageConfig.items[1] );
                    this.parseLines();
                }
            }
            this.checkCanSave();
        },

        unsetSelects: function( data ) {
            data.forEach( function( element ) {
                viewModel.set( "detailForm." + element, viewModel.get( "defaultDetailForm." + element ) );
            } );
        },

        save: function( event ) {
            var quotationId = AP.page.quotation.id;
            const parsedData = viewModel.get( "detailForm.data" );
            parsedData.quotationId = quotationId;
            var preview = $( "#signage-preview-container" )[0];

            html2canvas( preview ).then( function( canvas ) {
                const imgData = canvas.toDataURL( "image/png" ).replace( /^data:image\/png;base64,/, "" );
                parsedData.imageBase64 = imgData;

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotation-items",
                    data: JSON.stringify( parsedData ),
                    callback: {
                        done: function( xhr ) {
                            if( xhr.status == "ERRORE" ) {
                                if (xhr.data && xhr.data.error) {
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
    } );

    pub.new = function( onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/categories",
            callback: {
                done: function( xhr ) {
                    viewModel.get( "categories" ).data( xhr.data );
                    NM.util.openModal( AP.signage.fields.modalRoot );
                },
            },
        } );
        viewModel.resetForm();
        viewModel.set( "detailForm.data.quotationItem.quotationZone", AP.quotationDetail.detail.config().zone );
    };

    pub.edit = function( { id, onSave } ) {
        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/categories",
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
                                            }, 100 );
                                        }, 100 );
                                    }, 100 );
                                }, 100 );
                            }, 100 );
                        }, 100 );
                    }
                },
            },
        } );
    };

    pub.init = function() {
        kendo.bind( AP.signage.fields.modalRoot, viewModel );
    };

    return pub;
} () );
