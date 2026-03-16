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

    function pricingApp() {
        return AP.quotation.itemPricing;
    }

    function fileApp() {
        return AP.file.modal;
    }

    var pub = {};

    var defaultDetailForm = {
        data: {
            id: "",
            quotationItem: {
                id: "",
                quantity: 1,
                position: {
                    id: "",
                    code: ""
                },
                customImage: false,
                price: {
                    id: null,
                },
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
                special: false,
                customImage: false,
                status: {
                    id: "ACT",
                    name: "Attivo"
                },
                note: "",
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
        },
        statuses: AP.page.statuses,
        itemStatuses: AP.page.itemStatuses,
        title: "Carica segnaletica",
        canSave: false,
        productItemsNotes: [],
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
        cloneMode: false,

		zones: [],
		subzones: [],
		allZones: [],
        quotationZone: {
            "id": ""
        },
        quotationSubzone: {
            "id": ""
        },
        showCustomImage: false,
        showImage: true,

        //aggiunto per cambiare i parametri che determinano se mostrare l'immagine ricavata o quella custom quando cambio il valore della checkbox customImage
        toggleCustomImage: function( event ) {
            const value = event.target.checked
            viewModel.set('showCustomImage', value)
            viewModel.set('showImage', !value)

            return
        },

        //metodo che compone la struttura dati da passare al componente app-file, punto centralizzato di gestione del caricamento immagini
        openImagesList: function( event ) {

            var element = $( event.currentTarget );

            if ( !element.attr( "data-type" ) ) {
                console.error( "ERROR. Set data-type attribute in currentTarget" );
                return;
            }


            var type = element.data( "type" );
            var value = {
                type: type,
                id: viewModel.get('detailForm.data.quotationItem.id'),
                name: viewModel.get('detailForm.data.quotationItem.id'),
            };

            fileApp().open( value );

            return false;
        },

        changeZone: function() {
            const allZones = viewModel.get('allZones')
            viewModel.set('quotationSubzone', { "id": "" })
            viewModel.get('quotationSubzone')
            viewModel.set('subzones', [])
            if (viewModel.get('quotationZone.name') != '-- Tutte le zone') {
                let children = allZones.filter(z => z.origin && (z.origin.id == viewModel.get('quotationZone.id')))
                children.unshift({
                    "id": "",
                    "name": "\u00A0\u00A0- "
                })
                viewModel.set('subzones', children)
            }
            return;
        },

        isSubzoneEnabled: function() {
            return viewModel.get('quotationZone') && viewModel.get('quotationZone.name') != '-- Tutte le zone';
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
            viewModel.set( "detailForm.data.quotationItem.quotationZone", AP.quotation.detail.config().zone );

            $( "#signangeProductCategory" ).prop( "disabled", false );
            $( "#signageLine" ).prop( "disabled", false );
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
                items.unshift( { id: "", sizeName: "-- Altezza font" } );
                return items;
            }

            return [];
        },

        addSignageRow: function() {
            var ds = viewModel.get( "detailForm.data.quotationItem.signageRows" );
            if ( ds && ds.data().length < viewModel.get( "maxRows" ) ) {
                var defaultSignageRow = {
                    id: NM.util.uuid(),
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

        parseLines: async function( e ) {
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
                                } );
                            } );

                            Promise.all( promises ).then( () => {
                                viewModel.save();
                            } );
                        }
                    },
                } );
            }

            viewModel.get( "detailForm.data.quotationItem.signageRows" ).data().forEach( signageRow => {
                this.parsedLineContent( signageRow.content, signageRow.id );
                viewModel.updateCharCounter( {
                    currentTarget: document.getElementById( signageRow.uid + "_contentInput" )
                } );
            } );
            this.checkCanSave();
            AP.setUserPref( "signage.signageConfigId", viewModel.get( "detailForm.data.quotationItem.signageConfigItem.id" ) );
            AP.setUserPref( "signage.signageConfigRowCount", viewModel.get( "detailForm.data.quotationItem.signageConfigItem.rowCount" ) );
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
            const heightPx = signageConfigItem && signageConfigItem.heightInPixel ? signageConfigItem.heightInPixel * 1.4 : 16 * 1.4;

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
                "font-size": heightPx + "px",
                "line-height": heightPx + "px",
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
            const realContent = e.currentTarget?.value || 0;
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

        loadLines: async function( event ) {
            if (viewModel.get( "detailForm.data.signageConfig.catalogBundle.category.id" ) && viewModel.get( "detailForm.data.signageConfig.catalogBundle.category.id" ) != '') {
                await NM.util.ajax( {
                    method: "GET",
                    url: "/manager/ajax/quotations/lines/" + viewModel.get( "detailForm.data.signageConfig.catalogBundle.category.id" ),
                    callback: {
                        done: function( xhr ) {
                            xhr.data.unshift( { id: "", name: "-- Seleziona" } );
                            viewModel.get( "lines" ).data( xhr.data );
                        },
                    },
                } );
            }
            this.checkCanSave();
            AP.setUserPref( "signage.categoryId", viewModel.get( "detailForm.data.signageConfig.catalogBundle.category.id" ) );
        },

        loadModels: async function( event ) {
            if ( viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.id" ) != "" ) {
                if ( viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.code" ) != "LET00" ) {
                    $( "#quotation-signage-preview-background" ).css( {
                        width: "500px",
                        height: "500px"
                    } );
                } else {
                    $( "#quotation-signage-preview-background" ).css( {
                        width: "500px",
                        height: null
                    } );
                }
            }
            let url = "/manager/ajax/quotations/models/" + viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.id" )
            if (viewModel.get( "detailForm.data.signageConfig.catalogBundle.category" )) {
                url += "?catalogBundleCategoryId=" + viewModel.get( "detailForm.data.signageConfig.catalogBundle.category.id" )
            }
            await NM.util.ajax( {
                method: "GET",
                url: url,
                callback: {
                    done: function( xhr ) {
                        xhr.data.unshift( { id: "", name: "-- Seleziona il Modello" } );
                        viewModel.get( "models" ).data( xhr.data );
                    },
                },
            } );
            this.checkCanSave();
            AP.setUserPref( "signage.lineId", viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.id" ) );
        },

        loadFinishes: async function( event ) {
            if ( viewModel.get( "detailForm.data.signageConfig.catalogBundle.model.id" ) != "" ) {
                await NM.util.ajax( {
                    method: "GET",
                    url: "/manager/ajax/quotations/finishes/" + viewModel.get( "detailForm.data.signageConfig.catalogBundle.category.id" ) + "/" + viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.id" ),
                    callback: {
                        done: function( xhr ) {
                            xhr.data.unshift( { id: "", name: "-- Seleziona" } );
                            viewModel.get( "finishes" ).data( xhr.data );
                        },
                    },
                } );
            }
            this.checkCanSave();
            AP.setUserPref( "signage.modelId", viewModel.get( "detailForm.data.signageConfig.catalogBundle.model.id" ) );
        },

        loadSignageConfigs: async function( event ) {
            const xhr = await NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/signage-configs?categoryId="
                    + viewModel.get( "detailForm.data.signageConfig.catalogBundle.category.id" )
                    + "&lineId="
                    + viewModel.get( "detailForm.data.signageConfig.catalogBundle.line.id" )
                    + "&modelId="
                    + viewModel.get( "detailForm.data.signageConfig.catalogBundle.model.id" ),
				callback: {
					done: function (xhr) {
						//NOOP
					}
				}
            } );

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
				const xhr2 = await NM.util.ajax( {
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
						done: function (xhr) {
							//NOOP
						}
					}
				} );
				if ( xhr2.data.productId ) {
					viewModel.set( "detailForm.data.quotationItem.product.id", xhr2.data.productId );
                    viewModel.set( "detailForm.data.quotationItem.product.plateWidth", xhr2.data.plateWidth );
                    viewModel.set( "detailForm.data.quotationItem.product.plateHeight", xhr2.data.plateHeight );
                    viewModel.set( "detailForm.data.quotationItem.product.marginTop", xhr2.data.marginTop );
                    viewModel.set( "detailForm.data.quotationItem.product.marginLeft", xhr2.data.marginLeft );
				}
                if ( xhr2.data.file ) {
                    viewModel.set( "backgroundImage", xhr2.data.file );
                    viewModel.set( "backgroundImage.url", "url('" + xhr2.data.file.uri + "')" );
                } else {
                    viewModel.set( "backgroundImage.url", "" );
                }
                if (viewModel.get('detailForm.data.quotationItem') && viewModel.get('detailForm.data.quotationItem.id') && viewModel.get('detailForm.data.quotationItem.customImage')) {
                    await NM.util.ajax( {
                        method: "GET",
                        url: "/manager/ajax/quotation-items/" + viewModel.get('detailForm.data.quotationItem.id') + "/images" ,
                        callback: {
                            done: function( xhr ) {
                                if (xhr.data && xhr.data.length > 0 && xhr.data[0].uri) {
                                    viewModel.set( "backgroundCustomImage", xhr.data[0] );
                                    viewModel.set( "backgroundCustomImage.url", xhr.data[0].uri );
                                }
                            }
                        }
                    })
                }
			}


            this.checkCanSave();
            if ( viewModel.get( "detailForm.data.quotationItem.product.finish.id" ) != AP.getUserPref( "signage.finishId" ) ) {
                AP.deleteUserPref( "signage.product.items" );
            }
            AP.setUserPref( "signage.finishId", viewModel.get( "detailForm.data.quotationItem.product.finish.id" ) );
        },

        loadFontSizes: async function() {
            var signageConfig = viewModel.getSignageConfig();
            if ( signageConfig ) {
                await this.firstLoadProductItems();
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
            AP.setUserPref( "signage.fontId", viewModel.get( "detailForm.data.signageConfig.font.id" ) );
        },

        firstLoadProductItems: async function() {
            const quotationItemId = viewModel.get( "detailForm.data.quotationItem.id" );
            const productId = viewModel.get( "detailForm.data.quotationItem.product.id" );

			let marginLeft = viewModel.get('detailForm.data.quotationItem.product.marginLeft') || 0
			let marginTop = viewModel.get('detailForm.data.quotationItem.product.marginTop') || 0
			let plateWidth = viewModel.get('detailForm.data.quotationItem.product.plateWidth') || 0
			let plateHeight = viewModel.get('detailForm.data.quotationItem.product.plateHeight') || 0

			viewModel.set('detailForm.data.quotationItem.product.marginLeft', marginLeft +'px')
			viewModel.set('detailForm.data.quotationItem.product.marginTop', marginTop +'px')
			viewModel.set('detailForm.data.quotationItem.product.plateWidth', plateWidth +'px')
			viewModel.set('detailForm.data.quotationItem.product.plateHeight', plateHeight +'px')
			viewModel.set('detailForm.data.quotationItem.product.plateSizeAndMarginNotFilled', marginLeft <= 0 || marginTop <= 0 || plateWidth <= 0 || plateHeight <= 0)

            // Chiamata AJAX iniziale per ottenere tutti i product items
            await NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/product-items?productId=" + productId,
                callback: {
                    done: function( xhr ) {
                        if ( xhr.data.length > 0 ) {
                            viewModel.set( "detailForm.data.quotationItem.product.items", new kendo.data.DataSource() );
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
                // Se ci sono product items pre-selezionati, li carichiamo
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
                const getAllDescendantIndices = (startIndex, array) => {
                    const foundIndices = [];
                    // Partiamo dall'ID dell'elemento iniziale
                    const queue = [array[startIndex].attribute_id];

                    let i = 0;
                    while (i < queue.length) {
                        const currentParentId = queue[i];

                        // Cerchiamo nell'array tutti i figli di questo ID
                        array.forEach((item, index) => {
                            if (item.parent_attribute_id === currentParentId) {
                                // Se non abbiamo già aggiunto questo indice (evita loop infiniti)
                                if (!foundIndices.includes(index)) {
                                    foundIndices.push(index);
                                    // Aggiungiamo l'ID del figlio alla coda per cercare i SUOI figli nel prossimo giro
                                    queue.push(item.attribute_id);
                                }
                            }
                        });
                        i++;
                    }
                    return foundIndices;
                };
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

                                // Imposto selected sul parent
                                if ( parentIndex !== -1 ) {
                                    const parent = productItems.at( parentIndex );
                                    parent.get( "values" ).forEach( v => {
                                        v.selected = v.product_item_id == originId;
                                    } );
                                }

                                var lastAttributeId = null;
                                const attributes = [];
                                let attribute;
                                // Popolo i valori del nuovo attributo
                                xhr.data.forEach( function( item ) {
                                    if ( lastAttributeId == null || lastAttributeId != item.attribute.id ) {
                                        attribute = {
                                            attribute_id: item.attribute.id,
                                            attribute_name: item.attribute.name,
                                            parent_attribute_id: attributeId,
                                            parent_item_id: originId,
                                            level: attributeArray[parentIndex].level + 1,
                                            values: []
                                        };
                                        attributes.push( attribute );
                                    }
                                    attribute.values.push( {
                                        attributeValue: item.attributeValue,
                                        product_item_id: item.id,
                                        selected: false
                                    } );
                                    lastAttributeId = item.attribute.id;
                                } );
                                for ( let i = 0; i < attributes.length; i++ ) {
                                    productItems.insert( parentIndex + 1, attributes[i] );
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
                                            // aggiunto perche senza cercare i discendenti di secondo o piu livello, rimanevano dei residui dell'albero delle vecchie impostazioni
                                            let descendantIndexes = getAllDescendantIndices(idx, attributeArray)
                                            descendantIndexes.forEach( function(d) {
                                                elementsToRemove.push(d)
                                            } )
                                        }
                                    }
                                } );

                                elementsToRemove = elementsToRemove.sort((a, b) => b - a)
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
            var attributeArray = productItems.data();

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

                const emptyOption = $( "<option>" ).val( "" ).html( "-- Seleziona un valore" );
                select.append( emptyOption );

                values.forEach( function( attrValue ) {
                    const option = $( "<option>" )
                        .val( attrValue.product_item_id )
                        .html( `${attrValue.attributeValue.rawValue.name}` );
                    select.append( option );
                } );

                // Imposto la option selezionata
                const selectedOption = values.find( attrValue => attrValue.selected === true );
                if ( selectedOption ) {
                    select.val( selectedOption.product_item_id );
                }

                subContainer.append( select );
                if (selectedOption && selectedOption.attributeValue.allowNote) {
                    const labelNote = $( "<label>" );
                    labelNote.addClass( "mb-1" );
                    labelNote.css( "margin-left", ( 1.5 * item.level ) + "rem" );
                    labelNote.text( "NOTE" );
                    subContainer.append( labelNote );

                    let note = ''
                    if (viewModel.get('detailForm.data.quotationItem.items')) {
                        //cerco se il campo è censito, questo in pratica verifica se sono in edit o in new, perche in new non ho ancora questa struttura
                        campoPresenteNeiQuotationItemProductItems = viewModel.get('detailForm.data.quotationItem.items').find(i => i.productItem.attributeValue.rawValue.id == selectedOption.attributeValue.rawValue.id)
                        //se presente e con note (perche non tutti i campi hanno le note) e con nota valorizzata
                        if (campoPresenteNeiQuotationItemProductItems && campoPresenteNeiQuotationItemProductItems.note && campoPresenteNeiQuotationItemProductItems.note != '') {
                            //cerco nella struttura note dei product items che ho creato nel viewmodel. Se trovo qualcosa non lo sovvrascrivo, vuol dire che ho già caricato i dati e sto solo modificando il valore
                            const result = viewModel.detailForm.productItemsNotes.find(n =>
                                n.product_item_id === selectedOption.product_item_id &&
                                n.attribute_raw_value_id === selectedOption.attributeValue.id
                            );
                            //altrimenti setto per la prima volta la nota nella struttura del viewmodel con i dati provenienti dal backend
                            if (!result) {
                                viewModel.detailForm.productItemsNotes.push({
                                    product_item_id: selectedOption.product_item_id,
                                    attribute_raw_value_id: selectedOption.attributeValue.id,
                                    note: campoPresenteNeiQuotationItemProductItems.note
                                });
                                note = campoPresenteNeiQuotationItemProductItems.note
                            } else {
                                note = result.note
                            }
                        }
                    } else {
                        //non sono in edit o comunque ho modificato l'albero, non posso piu partire dai dati del detailForm,
                        // cerco se ho qualcosa in product items note. Se si, setto le note
                        let existing = viewModel.detailForm.productItemsNotes.find(n =>
                            n.product_item_id === selectedOption.product_item_id &&
                            n.attribute_raw_value_id === selectedOption.attributeValue.id
                        );
                        if (existing) {
                            note = existing.note;
                        }
                    }
                    //definisco il tag html e imposto onchange una funzione che cerca in product items notes dentro il viewmodel se trova un elemento per product item id e attribute value id
                    const inputNote = $( "<input>" ).addClass( "form-control me-3 mb-2" )
                    .on("input", function () {
                        let existing = viewModel.detailForm.productItemsNotes.find(n =>
                            n.product_item_id === selectedOption.product_item_id &&
                            n.attribute_raw_value_id === selectedOption.attributeValue.id
                        );

                        //se la trovo, imposto il valore della chiave note di quel elemento con il valore immesso nella input
                        if (existing) {
                            existing.note = this.value;
                        } else {
                            //altrimenti creo un nuovo elemento
                            viewModel.detailForm.productItemsNotes.push({
                                product_item_id: selectedOption.product_item_id,
                                attribute_raw_value_id: selectedOption.attributeValue.id,
                                note: this.value
                            });
                        }
                        note = this.value
                    });
                    inputNote.attr( "data-attribute-id", item.attribute_id );
                    inputNote.val(note)
                    if ( item.level > 0 ) {
                        inputNote.css( "margin-left", ( 1.5 * item.level ) + "rem" );
                        inputNote.css( "width", `calc(100% - ${1.5 * item.level}rem)` );
                    }
                    subContainer.append( inputNote );
                }
            } );
        },

        unsetSelects: function( data ) {
            data.forEach( function( element ) {
                viewModel.set( "detailForm." + element, viewModel.get( "defaultDetailForm." + element ) );
            } );
        },

        save: function( event ) {
            AP.loading.show();
            var quotationId = AP.page.quotation.id;

            //quando salvo, se sono in modalità custom image, devo scegliere il canvas dell'immagine custom da passare a 
            let preview = $( "#quotation-signage-preview-background" )[0];
            if (viewModel.get('detailForm.data.quotationItem') && viewModel.get('detailForm.data.quotationItem.id') && viewModel.get('detailForm.data.quotationItem.customImage') && viewModel.get('detailForm.data.quotationItem.customImage') == true) {
                //se non ho un immagine selezionata, ma sono in modalità custom image, vengo bloccato
               if (!viewModel.get('backgroundCustomImage.url')) {
                    AP.widget.notify( "error", "Hai scelto custom image, devi selezionare un'immagine prima di salvare." );
                    AP.loading.hide()
                    return false;
               }

               preview = $( "#quotation-signage-preview-custom-background" )[0];
            }
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
            parsedData.quotationItem.quotationZone = (viewModel.get('quotationSubzone.id') && viewModel.get('quotationSubzone.id') != '') ? viewModel.get('quotationSubzone') : viewModel.get('quotationZone')
            if (viewModel.get('cloneMode')) {
                parsedData.quotationItem.id = ""
            }

            //durante la save faccio passare le note dei product items e setto i valori nella struttura dati che passo al backend per il salvataggio
            const productItemsNotes = viewModel.detailForm.productItemsNotes
            parsedData.quotationItem.product.items._data.forEach(function (row) {
                const selectedOption = row.values.find(r => r.selected == true)
                if (selectedOption) {
                    const note = productItemsNotes.find(n =>
                        n.product_item_id === selectedOption.product_item_id &&
                        n.attribute_raw_value_id === selectedOption.attributeValue.id
                    );
                    if (note) {
                        row.note = note.note
                    }
                }
            })
            html2canvas( preview, { useCORS: true } ).then( function( canvas ) {
                const imgData = canvas.toDataURL( "image/png" ).replace( /^data:image\/png;base64,/, "" );
                parsedData.imageBase64 = imgData;
                parsedData.quotationItem.price = pricingApp().getData().data;

                AP.loading.show();
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotation-items/signage",
                    data: JSON.stringify( parsedData ),
                    callback: {
                        done: function( xhr ) {
                            $( "#signage-modal" ).hide();
                            AP.widget.notify( "success", "Segnaletica salvata nel preventivo." );
                            viewModel.set( "detailForm", defaultDetailForm );

                            setTimeout( function() {
                                AP.loading.hide();
                                window.location.reload();
                            }, 1000 );
                        },
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
            AP.deleteUserPref( "signage.categoryId" );
            AP.deleteUserPref( "signage.lineId" );
            AP.deleteUserPref( "signage.modelId" );
            AP.deleteUserPref( "signage.finishId" );
            AP.deleteUserPref( "signage.fontId" );
            AP.deleteUserPref( "signage.signageConfigId" );
            AP.deleteUserPref( "signage.product.items" );
            this.checkCanSave();
        },

        handleSelectChanges: function() {
            $( "#signangeProductCategory" ).on( "change", function(e) {
                viewModel.set( "detailForm.data.signageConfig.catalogBundle.line", { 'id':'' });
                viewModel.set( "detailForm.data.signageConfig.catalogBundle.model", { 'id':'' });
                viewModel.set( "detailForm.data.quotationItem.product.finish", { 'id':'' });
                viewModel.set( "detailForm.data.signageConfig.font", { 'id':'' });
                viewModel.set( "detailForm.data.quotationItem.signageConfigItem", { 'id':'' });
                viewModel.set( "detailForm.data.quotationItem.product.items", []);
                AP.deleteUserPref( "signage.lineId" );
                AP.deleteUserPref( "signage.modelId" );
                AP.deleteUserPref( "signage.finishId" );
                AP.deleteUserPref( "signage.fontId" );
                AP.deleteUserPref( "signage.signageConfigId" );
                AP.deleteUserPref( "signage.product.items" );
            } );
            $( "#signageLine" ).on( "change", function(e) {
                viewModel.set( "detailForm.data.signageConfig.catalogBundle.model", { 'id':'' });
                viewModel.set( "detailForm.data.quotationItem.product.finish", { 'id':'' });
                viewModel.set( "detailForm.data.signageConfig.font", { 'id':'' });
                viewModel.set( "detailForm.data.quotationItem.signageConfigItem", { 'id':'' });
                viewModel.set( "detailForm.data.quotationItem.product.items", []);
                AP.deleteUserPref( "signage.modelId" );
                AP.deleteUserPref( "signage.finishId" );
                AP.deleteUserPref( "signage.fontId" );
                AP.deleteUserPref( "signage.signageConfigId" );
                AP.deleteUserPref( "signage.product.items" );
            } );
            $( "#signageModel" ).on( "change", function(e) {
                viewModel.set( "detailForm.data.quotationItem.product.finish", { 'id':'' });
                viewModel.set( "detailForm.data.signageConfig.font", { 'id':'' });
                viewModel.set( "detailForm.data.quotationItem.signageConfigItem", { 'id':'' });
                viewModel.set( "detailForm.data.quotationItem.product.items", []);
                AP.deleteUserPref( "signage.finishId" );
                AP.deleteUserPref( "signage.fontId" );
                AP.deleteUserPref( "signage.signageConfigId" );
                AP.deleteUserPref( "signage.product.items" );
            } );
            $( "#signageFinish" ).on( "change", function(e) {
                viewModel.set( "detailForm.data.signageConfig.font", { 'id':'' });
                viewModel.set( "detailForm.data.quotationItem.signageConfigItem", { 'id':'' });
                viewModel.set( "detailForm.data.quotationItem.product.items", []);
                AP.deleteUserPref( "signage.fontId" );
                AP.deleteUserPref( "signage.signageConfigId" );
                AP.deleteUserPref( "signage.product.items" );
            } );
            $( "#signageFont" ).on( "change", function(e) {
                viewModel.set( "detailForm.data.quotationItem.signageConfigItem", { 'id':'' });
                viewModel.set( "detailForm.data.quotationItem.product.items", []);
                AP.deleteUserPref( "signage.signageConfigId" );
                AP.deleteUserPref( "signage.product.items" );
            } );
        }
    } );

    pub.new = async function( onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        pricingApp().init( "signage", undefined );

        let categoriesResponse = await NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/categories?typeId=SEG",
            callback: {
                done: function( xhr ) {
                    debugger
                    //NOOP
                }
            },
        } );

		if ( categoriesResponse.data.length > 0 ) {
            categoriesResponse.data = categoriesResponse.data.filter(c => c.type.id == 'SEG')
			categoriesResponse.data.unshift( { id: "", name: "-- seleziona" } );
			viewModel.get( "categories" ).data( categoriesResponse.data );
		}

		NM.util.openModal( AP.signage.fields.modalRoot );
        viewModel.resetForm();
        viewModel.set( "detailForm.data.quotationItem.quotationZone", AP.quotation.detail.config().zone );
        viewModel.handleSelectChanges()

        const signageCategoryId = AP.getUserPref( "signage.categoryId" )
        const signageLineId = AP.getUserPref( "signage.lineId" )
        const signageModelId = AP.getUserPref( "signage.modelId" )
        const signageFinishId = AP.getUserPref( "signage.finishId" )
        const signageFontId = AP.getUserPref( "signage.fontId" )
        const signageSignageConfigId = AP.getUserPref( "signage.signageConfigId" )
        const signageSignageConfigRowCount = AP.getUserPref( "signage.signageConfigRowCount" )

        if (signageCategoryId) {
            let category = viewModel.categories.data().find(c => c.id == signageCategoryId)
            if (category) {
                category = { id: category.id, name: category.name };
                viewModel.set( "detailForm.data.signageConfig.catalogBundle.category", category );
                await viewModel.loadLines();
                if ( signageLineId ) {
                    let line = viewModel.lines.data().find(l => l.id == signageLineId)
                    if (line) {
                        line = { id: line.id, name: line.name };
                        viewModel.set( "detailForm.data.signageConfig.catalogBundle.line", line );
                        await viewModel.loadModels();
                        if ( signageModelId ) {
                            let model = viewModel.models.data().find(m => m.id == signageModelId)
                            if (model) {
                                model = { id: model.id, name: model.name };
                                viewModel.set( "detailForm.data.signageConfig.catalogBundle.model", model );
                                await viewModel.loadFinishes();
                                if ( signageFinishId ) {
                                    let finish = viewModel.finishes.data().find(f => f.id = signageFinishId)
                                    if (finish) {
                                        finish = { id: finish.id, name: finish.name };
                                        viewModel.set( "detailForm.data.quotationItem.product.finish", finish );
                                        await viewModel.loadSignageConfigs();
                                        if ( signageFontId ) {
                                            let font = viewModel.fonts.data().find(f => f.id = signageFontId)
                                            if (font) {
                                                font = { id: font.id, name: font.name };
                                                viewModel.set( "detailForm.data.signageConfig.font", font)
                                                await viewModel.loadFontSizes();
                                                if ( signageSignageConfigId ) {
                                                    viewModel.set( "detailForm.data.quotationItem.signageConfigItem.id", signageSignageConfigId );
                                                    viewModel.set( "detailForm.data.quotationItem.signageConfigItem.rowCount", signageSignageConfigRowCount );
                                                    viewModel.parseLines();
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

		initPositionSuggest();

        const allZones = AP.quotation.detail.config().zones
        const parentZones = allZones.filter(z => !z.origin)

        viewModel.set('allZones', allZones)
        viewModel.set('zones', parentZones)
        const zone = AP.quotation.detail.config().zone
        if (zone.origin) {
            viewModel.set('quotationZone', zone.origin)
            viewModel.set('quotationSubzone', zone)
            const children = allZones.filter(z => z.origin && (z.origin.id == zone.origin.id))
            children.unshift({
                "id": "",
                "name": "\u00A0\u00A0- "
            })
            viewModel.set('subzones', children)
        } else {
            viewModel.set('quotationZone', zone)
            const children = allZones.filter(z => z.origin && (z.origin.id == zone.id))
            children.unshift({
                "id": "",
                "name": "\u00A0\u00A0- "
            })
            viewModel.set('subzones', children)
            viewModel.set('quotationSubzone', { "id": "" })
        }
    };

    var initPositionSuggest = function() {

        var suggest = $( "#signage-quotation-item-pricing-box-position" );
        var autocomplete = suggest.data( "kendoAutoComplete" );
        var suggestTemplate = $( "#quotation-position-suggest-row-tmpl" ).html();

        if ( autocomplete ) {
            return;
        }

        suggest.keypress( function( event ) {
            if ( event.keyCode == 13 ) {
                return false;
            }
        } );

        suggest.kendoAutoComplete( {
            template: $.proxy( kendo.template( suggestTemplate ) ),
            height: "auto",
            dataTextField: "term",
            highlightFirst: true,
            minLength: 2,
            dataSource: new kendo.data.DataSource( {
                serverFiltering: true,
                transport: {
                    read: {
                        url: "/manager/ajax/quotations/zones/" + viewModel.get( "detailForm.data.quotationItem.quotationZone.id" ) + "/positions",
                        data: {
                            str: function() {
                                return suggest.data( "kendoAutoComplete" ).value();
                            },
                        },
                    },
                    parameterMap: function( data, type ) {
                        if ( type === "read" ) {
                            return { "str": data.str()  };
                        }
                    }
                },
                schema: {
                    data: function( xhr ) {
                        return xhr.data;
                    }
                },
            } ),
            noDataTemplate: false,

            change: function( e ) {
                var value = this.value();
                var exists = this.dataSource.data().find( item => item.code === value );

                if ( !exists ) {
                    var position = { id: "", code: value };
                    console.log( "suggest:Inserito nuovo elemento:", value );
                    viewModel.set( "detailForm.data.quotationItem.position", position );
                }
            },

            select: function( event ) {
                var position = this.dataItem( event.item.index() );
                console.log( "suggest:position:", position );

                viewModel.set( "detailForm.data.quotationItem.position", position );
                var sel = viewModel.get( "detailForm.data.quotationItem.position" );
                console.log( "sel", sel );
            }
        } );

    };

    pub.edit = async function( { id, clone = false, onSave } ) {
        viewModel.resetForm();

        const categoriesResponse = await NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/categories?typeId=SEG",
            callback: {
                done: function( xhr ) {
                    //NOOP
                },
            },
        } );

		categoriesResponse.data.unshift( { id: "", name: "" } );
		viewModel.get( "categories" ).data( categoriesResponse.data );
		NM.util.openModal( AP.signage.fields.modalRoot );

        const signageResponse = await NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotation-items/signage/" + id,
            callback: {
                done: async function( xhr ) {
					// NOOP
                },
            },
        } );
		var data = signageResponse.data;

		viewModel.set( "detailForm.title", "Modifica segnaletica" );

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
        viewModel.set('detailForm.data.quotationItem.customImage', viewModel.get('detailForm.data.quotationItem.customImage') == 'true')
        viewModel.set('detailForm.data.quotationItem.special', viewModel.get('detailForm.data.quotationItem.special') == 'true')
        viewModel.set( "detailForm.data.quotationItem.position", data.quotationItem.position ?? { 'id': '', 'code': '' })

		var ds = viewModel.get( "detailForm.data.quotationItem.signageRows" );

		if ( ds && ds.data().length ) {
			ds.data().forEach( function( row, i ) {
				row.set( "index", i + 1 );
			} );
		}

		await viewModel.loadLines();
		await viewModel.loadModels();
		await viewModel.loadFinishes();
		await viewModel.loadSignageConfigs();
		await viewModel.loadFontSizes();
		await viewModel.parseLines();
		await ds.data().forEach( row => {
			viewModel.updateCharCounter( {
				currentTarget: document.getElementById( row.uid + "_contentInput" )
			} );
		} );
		NM.util.openModal( AP.signage.fields.modalRoot );
		viewModel.setSelectedTextAlignIcon();

		pricingApp().init( "signage", { data: signageResponse.data.quotationItem.price } );
		initPositionSuggest();

        const allZones = AP.quotation.detail.config().zones
        const parentZones = allZones.filter(z => !z.origin)

        viewModel.set('allZones', allZones)
        viewModel.set('zones', parentZones)

        if (viewModel.get('detailForm.data.quotationItem.quotationZone.origin')) {
            viewModel.set('quotationZone', viewModel.get('detailForm.data.quotationItem.quotationZone.origin'))
            viewModel.set('quotationSubzone', viewModel.get('detailForm.data.quotationItem.quotationZone'))
            const children = allZones.filter(z => z.origin && (z.origin.id == viewModel.get('detailForm.data.quotationItem.quotationZone.origin.id')))
            children.unshift({
                "id": "",
                "name": "\u00A0\u00A0- "
            })
            viewModel.set('subzones', children)
        } else {
            viewModel.set('quotationZone', viewModel.get('detailForm.data.quotationItem.quotationZone'))
            const children = allZones.filter(z => z.origin && (z.origin.id == viewModel.get('detailForm.data.quotationItem.quotationZone.id')))
            children.unshift({
                "id": "",
                "name": "\u00A0\u00A0- "
            })
            viewModel.set('subzones', children)
            viewModel.set('quotationSubzone', { "id": "" })
        }

        if (clone) {
            viewModel.set('cloneMode', true)
            viewModel.set('detailForm.title', "Clona Segnaletica")
            $('#save-button').css("display", "none")
            $('#clone-button').css("display", "block")
        } else {
            viewModel.set('cloneMode', false)
            $('#save-button').css("display", "block")
            $('#clone-button').css("display", "none")
        }

        //in base al bool di customImage setto questi due parametri, se showCustomImage mostrerò il div con l'immagine custom e nasconderò quello con l'immagine composta dai vari attributes
        //altrimenti farò il contrario
        viewModel.set('showCustomImage', viewModel.get('detailForm.data.quotationItem.customImage'))
        viewModel.set('showImage', !viewModel.get('detailForm.data.quotationItem.customImage'))

        viewModel.handleSelectChanges()

        AP.loading.hide();

		let marginLeft = viewModel.get('detailForm.data.quotationItem.product.marginLeft') || 0
		let marginTop = viewModel.get('detailForm.data.quotationItem.product.marginTop') || 0
		let plateWidth = viewModel.get('detailForm.data.quotationItem.product.plateWidth') || 0
		let plateHeight = viewModel.get('detailForm.data.quotationItem.product.plateHeight') || 0

		viewModel.set('detailForm.data.quotationItem.product.marginLeft', marginLeft +'px')
		viewModel.set('detailForm.data.quotationItem.product.marginTop', marginTop +'px')
		viewModel.set('detailForm.data.quotationItem.product.plateWidth', plateWidth +'px')
		viewModel.set('detailForm.data.quotationItem.product.plateHeight', plateHeight +'px')
		viewModel.set('detailForm.data.quotationItem.product.plateSizeAndMarginNotFilled', marginLeft <= 0 || marginTop <= 0 || plateWidth <= 0 || plateHeight <= 0)
	};

    pub.init = function() {
        kendo.bind( AP.signage.fields.modalRoot, viewModel );
    };

    pub.getItem = function() {
        return viewModel.get( "detailForm.data" );
    };

    return pub;
} () );
