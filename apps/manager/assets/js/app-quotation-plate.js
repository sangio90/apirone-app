AP.namespace( "plate" );

Object.assign( AP.plate.fields, {
    modalRoot: $( "#plate-modal-root" ),
} );

$( document ).ready( function() {

    if ( AP.plate.fields.modalRoot.length ) {

        AP.plate.modal.init( { container: AP.plate.fields.modalRoot } );
    }

} );

AP.plate.modal = ( function() {

    const gridModule = AP.plate.grid;
    const fields = AP.plate.fields;

    function pricingApp() {
        return AP.quotation.itemPricing;
    }

    const {
        constants,
        orientation,
        CELL_TYPE,
        Plate,
        Cell,
        Fruit,
        FruitsController
    } = gridModule;

    var pub = {
        fruitsController: null,
    };

    const settings = {
        container: null,
    };

    // --- Frutti: mapping per griglia, create, config plate ---
    var mapFruitForPlate = function( data ) {

        var fruit = {
            id: data.id, // ID univoco dell'istanza generato da createFruit()
            fruitId: data.fruitId, // ID del prodotto frutto originale
            width: constants.GRID_CELL_DIMENSIONS[gridModule.CELL_TYPE.FREE].width * data.fruit.positionCount,
            height: constants.GRID_CELL_DIMENSIONS[gridModule.CELL_TYPE.FREE].height,
            columnSpan: data.fruit.positionCount,
            rowSpan: 1,
            code: data.fruit.code,
            name: data.fruit.name,
            image: data.fruit?.horizontalImage?.uri ?? "/assets/main/img/fruit-generic.png"
        };

        return fruit;

    };

    var createFruit = function( data ) {
        // QuotationItemFruis
        // data: { position: 1, fruit: { id: "", name: "" }, items: [], quotationItemFruitId: null }

        var fruit = data;

        // Genera ID univoco per questa istanza
        // fruit.id = NM.util.uuid();
        fruit.fruitId = data.fruit.id; // ID del prodotto frutto originale
        fruit.id = data.id || NM.util.uuid(); // ID DB del frutto (solo in modifica)
        fruit.positionIds = data.positionIds || []; // ID delle celle occupate dal frutto

        fruit.items = new kendo.data.DataSource( {
            data: [],
            schema: {
                model: { id: "id" } // than, can i use get()
            }
        } );

        fruit.expanded = true; // Default: accordion aperto

        // console.log( "createFruit", fruit );

        return fruit;

    };

    var configPlate = function() {

        var plate = viewModel.get( "plate" );

        console.log( "plate.image", plate );

        let freeCellWidth = constants.GRID_CELL_DIMENSIONS[ gridModule.CELL_TYPE.FREE ].width;
        let freeCellHeight = constants.GRID_CELL_DIMENSIONS[ gridModule.CELL_TYPE.FREE ].height;

        if ( plate.cellOrientation.id == orientation.VERTICAL ) {
            const tmp = freeCellWidth;
            freeCellWidth = freeCellHeight;
            freeCellHeight = tmp;
        }

        gridModule.setCellDimensions( freeCellWidth, freeCellHeight );

        const grid = [];

        // create grid
        for ( let iRow = 0; iRow < plate.grid.length; iRow++ ) {
            const row = [];

            for (
                let iCol = 0;
                iCol < plate.grid[iRow].length;
                iCol++
            ) {
                // const cellType = plate.grid[iRow][iCol];

                const cellData = plate.grid[iRow][iCol];
                const cellType = cellData.type;

                const cell = new Cell(
                    constants.GRID_CELL_DIMENSIONS[cellType].width,
                    constants.GRID_CELL_DIMENSIONS[cellType].height,
                    plate.cellOrientation.id,
                    cellType,
                    cellData.id
                );

                row.push( cell );
            }

            grid.push( row );
        }

        const plateObj = new Plate( {
            width: plate.width,
            height: plate.height,
            orientation: plate.orientation.id,
            cellOrientation: plate.cellOrientation.id,
            id: plate.id,
            code: plate.code,
            image: plate.image.uri,
            grid: grid,
            isSpecial: false,
        } );

        // console.log( "fruits:fruitList", fruitList );

        pub.fruitsController = new FruitsController( {
            plate: plateObj,
            fruits: [],
        } );

        pub.fruitsController.plate.drawGridWithin( $( ".plate-designer" ) );

        // se ci sono frutti li reinserisco
        // var fruitList = [];

        var fruits = viewModel.get( "detailForm.data.fruits" );

        if ( fruits.total() ) {
            for ( var thisFruit of fruits.data() ) {
                var obj = mapFruitForPlate( thisFruit );
                pub.fruitsController.addFruitToPlate( obj );
            };
        }

        viewModel.set( "isPlateDefined", true );

    };

    // --- Default form e plate (struttura dati iniziale) ---
    // Factory: restituisce una copia fresca ogni volta (evita accumulo dati tra aperture consecutive)
    var createDefaultDetailForm = function() {
        return {
            data: {
                // quotationItemId: "",
                id: "",
                quantity: 1,
                // price: 0,
                special: false,
                note: '',
                status: {
                    id: "ACT"
                },
                position: {
                    id: "",
                    code: ""
                },
                quotationZone: {
                    id: "",
                    name: ""
                },
                product: {
                    id: "",
                    orientation: {
                        id: ""
                    },
                    frame: {
                        id: ""
                    },
                    finish: {
                        id: ""
                    },
                    line: {
                        id: ""
                    },
                    model: {
                        id: "",
                        code: ""
                    },
                    image: {
                        id: "",
                        uri: ""
                    },
                    items: new kendo.data.DataSource(),
                },
                fruits: new kendo.data.DataSource( {
                    data: [],
                    schema: {
                        model: { id: "id" }
                    }
                } )
            },
            statuses: AP.page.statuses,
            itemStatuses: AP.page.itemStatuses,
            title: "Carica placca",
            canSave: false,
            isClone: false,
            priceTypes: [
                { id: "C", name: "Calcolato" },
                { id: "F", name: "Fisso" },
            ],
        };
    };

    var defaultPlate = {
        id: "100",
        code: "508",
        image: {
            uri: "",
        },
        width: 1200, // in px
        height: 500, // in px
        orientation: {
            id: ""
        },
        cellOrientation: {
            id: ""
        },
        grid: [
            // LEGEND:
            // "_" - empty free space
            // "0" - prohibited space
            [
                { type: "_", id: "default-cell-1" },
                { type: "_", id: "default-cell-2" },
            ],
        ],
    };

    var applyUserPrefIfNewMode = function( prefKey, viewModelPath, selector ) {
        var value = AP.getUserPref( prefKey );

        if ( value && value !== "undefined" && !viewModel.get( "isEditMode" ) ) {
            viewModel.set( viewModelPath, value );
            if ( selector ) {
                $( selector ).trigger( "change" );
            }
        }
    };

    var updatePrice = function() {

        pricingApp().update();

    };

    /**
     * Resetta il detailForm del viewModel sostituendolo con una copia fresca.
     * Per essere più veloci si può resettare campo per campo anziché sostituire l'oggetto completo.
     */
    var resetDetailForm = function() {
        viewModel.set( "detailForm", createDefaultDetailForm() );
    };

    // --- ViewModel (Kendo ObservableObject) ---
    var viewModel = new kendo.data.ObservableObject( {

        detailForm: createDefaultDetailForm(),

        lines: new kendo.data.DataSource(),
        models: new kendo.data.DataSource(),
        finishes: new kendo.data.DataSource(),

        plate: defaultPlate,
        availableOrientations: [],

        currentFruit: {},

        toggleFruitsLabel: "Comprimi tutti",

		zones: [],
		subzones: [],
		allZones: [],

        isEditMode: false,
		loadZones: async function( e ) {
			return await NM.util.ajax( {
				method: "GET",
				url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/zones",
				callback: {
					done: function( xhr ) {
						let allZones
						let zones
						if ( xhr.data.length ) {
							allZones = xhr.data;
						} else {
							allZones = [];
						}
						viewModel.set("allZones", allZones);
						zones = allZones.filter( function( zone ) {
							return !zone.origin
						});
						viewModel.set( "zones", zones);
					}
				}
			} );
		},

		loadSubZones: function (quotationZone) {
			this.set("detailForm.data.quotationSubzone", null);

			if (!quotationZone) {
				this.set("subzones", []);
				return;
			}

			var allZones = this.get("allZones")

			var filtered = allZones.filter(function (z) {
				return z.origin && z.origin.id === quotationZone.id;
			});

			this.set("subzones", filtered);
		},

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },
        updatePricing() {

            updatePrice();

            return false;
        },

        getFruitCount() {
            return this.get( "detailForm.data.fruits" ).total();
        },

        removeFruit( event ) {
            viewModel.get( "detailForm.data.fruits" ).remove( event.data );
            pub.fruitsController.removeFruit( event.data.id );
        },

        goToProduct( event ) {

            var id = this.get( "detailForm.data.product.id" );
            var uri = "/manager/products/" + id + "/detail";

            window.open( uri, "_blank" ).focus();
        },

        toggleFruit( event ) {
            event.data.set( "expanded", !event.data.get( "expanded" ) );
        },

        changeOrientation( event ) {
            var orientationId = this.get( "detailForm.data.product.orientation.id" );

            var frameId = viewModel.get( "detailForm.data.product.frame.id" );
            var productId = viewModel.get( "detailForm.data.product.id" );

            AP.plate.api.getFrameForOrientation( frameId, orientationId, productId, {
                done: function( xhr ) {
                    viewModel.set( "plate.orientation", xhr.data.orientation );
                    viewModel.set( "plate.cellOrientation", xhr.data.cellOrientation );
                    viewModel.set( "plate.grid", xhr.data.grid );
                    viewModel.set( "plate.image", xhr.data.image );
                    viewModel.set( "detailForm.data.product.orientation", xhr.data.orientation );
                    configPlate();
                }
            } );

        },

        toggleFruits( event ) {
            var fruits = this.get( "detailForm.data.fruits" );
            var currentLabel = this.get( "toggleFruitsLabel" );
            var newExpandedState = currentLabel === "Espandi tutti";

            fruits.data().forEach( function( fruit ) {
                fruit.set( "expanded", newExpandedState );
            } );

            this.set( "toggleFruitsLabel", newExpandedState ? "Comprimi tutti" : "Espandi tutti" );
        },

        /**
         * Carica la placca (griglia, orientamento, immagine) in base al frame del modello.
         * @returns {*} Thenable restituita da getFrame (per incatenare in edit()).
         */
        loadPlate: function( orientation ) {
            var modelId = this.get( "detailForm.data.product.model.code" );
            var image = this.get( "detailForm.data.product.image" );

            console.log( "modelId", modelId );

            // get plate/frame by code
            // for plate, code of frame is the same code of model
            const frame = AP.page.frames
                .find( frame => frame.code === modelId )
                ?? "";

            if ( !frame ) {
                AP.widget.notify( "error", "Modello [" + modelId + "] non trovato. Impossibile continuare." );
                return;
            }

            var frameId = frame.id;

            this.set( "detailForm.data.product.frame.id", frameId );

            return AP.plate.api.getFrame( frameId, {
                done: function( xhr ) {


                    console.log( "getFrame", xhr );

                    viewModel.set( "plate.id", xhr.data.id );
                    viewModel.set( "plate.code", xhr.data.code );
                    viewModel.set( "plate.width", xhr.data?.width ?? 1200 );
                    viewModel.set( "plate.height", xhr.data?.height ?? 500 );
                    viewModel.set( "plate.orientation", xhr.data.orientation );
                    viewModel.set( "detailForm.data.product.orientation", orientation ?? xhr.data.orientation );
                    viewModel.set( "plate.cellOrientation", xhr.data.cellOrientation );
                    viewModel.set( "availableOrientations", xhr.data.availableOrientations );
                    viewModel.set( "plate.grid", xhr.data.grid );
                    viewModel.set( "plate.image", image );
                    viewModel.set( "plate.grid", xhr.data.grid );

                    if ( orientation ) {
                        viewModel.changeOrientation();
                    }

                    configPlate();
                }
            } );

        },

        /**
         * Primo caricamento degli attributi (product items) per il prodotto placca.
         * Popola il DataSource product.items e, se in modifica, ripristina le selezioni da quotation item.
         * Restituisce la thenable dell’ajax così il chiamante può incatenare (es. .then(loadPlate)).
         * @returns {*} Thenable restituita da getProductItems().then(...)
         */
        firstLoadProductItems: function() {
            var quotationItemId = viewModel.get( "detailForm.data.id" );
            var productId = viewModel.get( "detailForm.data.product.id" );

            return AP.plate.api.getProductItems( productId, null, {
                done: function( xhr ) {
                    if ( xhr.count > 0 ) {
                        var image = xhr.data[0].horizontalImage || xhr.data[0].verticalImage;
                        if ( !viewModel.get( "detailForm.data.product.image" ) && image ) {
                            viewModel.set( "detailForm.data.product.image", image );
                            viewModel.set( "backgroundImage", image );
                            viewModel.set( "backgroundImage.url", "url('" + image.uri + "')" );
                        }
                        viewModel.set( "detailForm.data.product.items", new kendo.data.DataSource() );
                        var productItems = viewModel.get( "detailForm.data.product.items" );
                        var attributeArray = productItems.data();
                        xhr.data.forEach( function( item ) {
                            var existing = attributeArray.find( function( d ) { return d.attributeId === item.attribute.id; } );
                            if ( existing ) {
                                if ( !existing.values.find( function( v ) { return v.productItemId === item.id; } ) ) {
                                    existing.values.push( {
                                        attributeValue: item.attributeValue,
                                        productItemId: item.id,
                                        images: item.images,
                                        selected: false
                                    } );
                                    productItems.trigger( "change" );
                                }
                            } else {
                                productItems.add( {
                                    attributeId: item.attribute.id,
                                    attributeName: item.attribute.name,
                                    level: 0,
                                    values: [ {
                                        attributeValue: item.attributeValue,
                                        productItemId: item.id,
                                        images: item.images,
                                        selected: false
                                    } ]
                                } );
                            }
                        } );
                        viewModel.renderProductItemsPlate();
                    }
                }
            } ).then( async function() {
                if ( quotationItemId && quotationItemId.length ) {
                    await AP.plate.api.getQuotationItemProductItems( quotationItemId, {
                        done: async function( xhr ) {
                            await viewModel.restoreProductItemSelections( xhr.data, "#quotation-plate-product-items" );
                        }
                    } );
                }
            } );
        },

        /**
         * Ripristina le selezioni dei product items salvati nelle select del DOM.
         * Ordina per orderby, poi per ogni item trova la select corrispondente,
         * imposta il valore e carica i figli (await loadProductItems).
         * Usato sia per la placca che per i frutti in editing.
         * @param {Array} data - Array di quotation item product items dall'API
         * @param {string} containerSelector - Selettore jQuery del container delle select
         * @param {string} [fruitId] - Se presente, passa fruitId a loadProductItems
         */
        restoreProductItemSelections: async function( data, containerSelector, fruitId ) {
            // Ordina per orderby: il primo livello deve essere processato prima del secondo
            data.sort( function( a, b ) { return a.productItem.orderby - b.productItem.orderby; } );
            if ( data.length > 0 ) {
                var container = $( containerSelector );
                for ( var qi = 0; qi < data.length; qi++ ) {
                    var qipi = data[qi];
                    var sel = container.find( "select[data-attribute-id=\"" + qipi.productItem.attribute.id + "\"]" );
                    if ( sel.length > 0 ) {
                        sel.val( qipi.productItem.id );
                        await viewModel.loadProductItems( qipi.productItem.id, qipi.productItem.attribute.id, fruitId );
                    }
                }
            }
        },

        /**
         * Carica i product items (attributi) figli di un attributo selezionato.
         * Gestisce sia placca che frutti, supporta più attributi con stesso parent, e rimuove elementi orfani.
         * Logica allineata a signage.js (che funziona correttamente).
         * NOTA: i confronti tra ID usano == (loose equality) perché originId è stringa (da select.val())
         *       mentre productItemId può essere numero (da AJAX response).
         * @param {string} originId - ID del product item selezionato (vuoto = deselezionamento)
         * @param {string} attributeId - ID dell'attributo selezionato
         * @param {string} [fruitId] - Se presente, carica items per il frutto invece che per la placca
         */
        loadProductItems: function( originId, attributeId, fruitId ) {
            var type; var product; var productItems; var prodyctIdForCall; var productId;

            if ( fruitId === undefined ) {
                type = "plate";
                product = viewModel.get( "detailForm.data.product" );
                productItems = viewModel.get( "detailForm.data.product.items" );
                prodyctIdForCall = product.get( "id" );
            } else {
                type = "fruit";
                var fruits = viewModel.get( "detailForm.data.fruits" );
                product = fruits.get( fruitId );
                productItems = product.get( "items" );
                prodyctIdForCall = product.get( "fruit.id" );
            }

            productId = product.get( "id" );
            var attributeArray = productItems.data();
            originId = originId || "";

            // --- Funzione di render locale ---
            function doRender() {
                if ( type === "plate" ) {
                    viewModel.renderProductItemsPlate( true );
                } else {
                    viewModel.renderProductItemsFruit( productId, true );
                }
            }

            // --- Deselezionamento: originId vuoto ---
            if ( originId === "" ) {
                var actualIndex = null;
                for ( var i = attributeArray.length - 1; i >= 0; i-- ) {
                    if ( attributeArray[i].attributeId == attributeId ) {
                        actualIndex = i;
                        attributeArray[i].values.forEach( function( attrValue ) {
                            attrValue.selected = false;
                        } );
                    }
                }
                // Rimuovo attributi figli
                if ( actualIndex !== null ) {
                    var idx = actualIndex + 1;
                    while ( idx < attributeArray.length ) {
                        if ( attributeArray[idx].level > attributeArray[actualIndex].level ) {
                            productItems.remove( attributeArray[idx] );
                        } else {
                            break;
                        }
                    }
                }
                doRender();
                return;
            }

            // --- Selezionamento: originId valorizzato ---
            return AP.plate.api.getProductItems( prodyctIdForCall, originId, {
                done: function( xhr ) {
                    if ( xhr.data.length > 0 ) {
                        // Trovo l'indice dell'attributo selezionato
                        var parentIndex = -1;
                        attributeArray.forEach( function( d, idx ) {
                            if ( d.attributeId == attributeId ) { parentIndex = idx; }
                        } );

                        // Rimuovo eventuali attributi figli
                        var i = parentIndex + 1;
                        while ( i < attributeArray.length ) {
                            if ( attributeArray[i].level > attributeArray[parentIndex].level ) {
                                productItems.remove( attributeArray[i] );
                            } else {
                                break;
                            }
                        }

                        // Imposto selected sul parent
                        if ( parentIndex !== -1 ) {
                            var parent = productItems.at( parentIndex );
                            parent.get( "values" ).forEach( function( v ) {
                                v.selected = v.productItemId == originId;
                            } );
                        }

                        // Creo i nuovi attributi figli
                        var lastAttributeId = null;
                        var attributes = [];
                        var attribute;

                        xhr.data.forEach( function( item ) {
                            if ( lastAttributeId == null || lastAttributeId != item.attribute.id ) {
                                attribute = {
                                    attributeId: item.attribute.id,
                                    attributeName: item.attribute.name,
                                    parentAttributeId: attributeId,
                                    parentItemId: originId,
                                    level: attributeArray[parentIndex].level + 1,
                                    values: []
                                };
                                attributes.push( attribute );
                            }
                            attribute.values.push( {
                                attributeValue: item.attributeValue,
                                productItemId: item.id,
                                selected: false
                            } );
                            lastAttributeId = item.attribute.id;
                        } );

                        // Inserisco i nuovi attributi dopo il parent
                        for ( var i = 0; i < attributes.length; i++ ) {
                            productItems.insert( parentIndex + 1 + i, attributes[i] );
                        }

                    } else {
                        // Nessun figlio: setto selected sul parent e rimuovo eventuali orfani
                        var parentIndex = -1;
                        attributeArray.forEach( function( d, idx ) {
                            if ( d.attributeId == attributeId ) { parentIndex = idx; }
                        } );

                        if ( parentIndex !== -1 ) {
                            var parent = productItems.at( parentIndex );
                            parent.get( "values" ).forEach( function( v ) {
                                v.selected = v.productItemId == originId;
                            } );
                        }

                        // Rimuovo elementi dell'albero legati a un parent non selezionato (come in signage.js)
                        var elementsToRemove = [];
                        attributeArray.forEach( function( d, idx ) {
                            if ( d.parentItemId ) {
                                if ( idx > 0 && attributeArray[idx - 1].values.filter( function( v ) {
                                    return v.selected == false && v.productItemId == d.parentItemId;
                                } ).length > 0 ) {
                                    elementsToRemove.push( idx );
                                }
                            }
                        } );
                        elementsToRemove.reverse().forEach( function( idx ) {
                            productItems.remove( productItems.at( idx ) );
                        } );
                    }

                    // Render
                    doRender();

                    // Aggiorna pricing sui select
                    $( "select.select-item" ).each( function() {
                        $( this ).off( "change.calculatePrice" ).on( "change.calculatePrice", function() {
                            updatePrice();
                        } );
                    } );
                }
            } );
        },

        populateProduct( product ) { // without items

            if ( product.horizontalImage ) {
                var image = product?.horizontalImage;
            } else {
                var image = product?.verticalImage;
            }

            viewModel.set( "detailForm.data.product.id", product?.id ); // "" = nuovo
            viewModel.set( "detailForm.data.product.finish.id", product.finish.id );
            viewModel.set( "detailForm.data.product.model.id", product.model.id );
            viewModel.set( "detailForm.data.product.model.code", product.model.code ); // for frame
            viewModel.set( "detailForm.data.product.line.id", product.line.id );
            viewModel.set( "detailForm.data.product.image.id", image?.id );
            viewModel.set( "detailForm.data.product.image.uri", image?.uri );

        },

        /**
         * Carica il prodotto (linea/modello/finitura) e i suoi product items, poi la placca.
         * Chiamato al change della finitura (nuova placca).
         */
        loadProduct: function() {
            var lineId = viewModel.get( "detailForm.data.product.line.id" );
            var modelId = viewModel.get( "detailForm.data.product.model.id" );
            var finishId = viewModel.get( "detailForm.data.product.finish.id" );
            AP.setUserPref( "plate.finishId", finishId );

            AP.plate.api.getProductByParams( 22, lineId, modelId, finishId, {
                done: function( xhr ) {
                    viewModel.populateProduct( xhr.data );
                    viewModel.firstLoadProductItems().then( function() {
                        setTimeout( function() {
                            viewModel.loadPlate();
                        }, 500 );
                    } );
                }
            } );
        },

        addProductItemsToFruit: function( fruitId ) {

            var fruits = viewModel.get( "detailForm.data.fruits" );
            var thisFruit = fruits.get( fruitId );
            var productId = thisFruit.fruit.id;

            AP.plate.api.getProductItems( productId, null, {
                done: function( xhr ) {
                    if ( xhr.count > 0 ) {
                        var thisImage = xhr.data[0].horizontalImage;
                        if ( thisImage ) {
                            thisFruit.set( "fruit.horizontalImage", thisImage );
                            pub.fruitsController.updateFruit( thisFruit.id, { image: thisImage.uri } );
                        }
                        var fruitItems = thisFruit.get( "items" );
                        var attributeArray = fruitItems.data();
                        xhr.data.forEach( function( item ) {
                            const attributeExisting = attributeArray.find( function( d ) { return d.attributeId === item.attribute.id; } );
                            var img = item.images && item.images[0];
                            if ( img ) {
                                thisFruit.set( "fruit.horizontalImage", img );
                                pub.fruitsController.updateFruit( thisFruit.id, { image: img.uri } );
                            }
                            if ( attributeExisting ) {
                                attributeExisting.values.push( {
                                    attributeValue: item.attributeValue,
                                    productItemId: item.id,
                                    images: item.images,
                                    selected: false
                                } );
                            } else {
                                fruitItems.add( {
                                    attributeId: item.attribute.id,
                                    attributeName: item.attribute.name,
                                    level: 0,
                                    values: [ {
                                        attributeValue: item.attributeValue,
                                        productItemId: item.id,
                                        images: item.images,
                                        selected: false
                                    } ]
                                } );
                            }
                        } );
                        thisFruit.set( "items", fruitItems );
                        viewModel.renderProductItemsFruit( fruitId );
                    }
                }
            } ).then( async function() {
                var fruits = viewModel.get( "detailForm.data.fruits" );
                var thisFruit = fruits.get( fruitId );
                var quotationItemFruitId = thisFruit.get( "id" );

                if ( quotationItemFruitId ) {
                    await AP.plate.api.getQuotationItemFruitProductItems( quotationItemFruitId, {
                        done: async function( xhr ) {
                            await viewModel.restoreProductItemSelections( xhr.data, "#quotation-fruit-row-items_" + fruitId, fruitId );
                        }
                    } );
                }
            } );

        },

        changeImage: function( attribute ) {

            var uri = "";

            var orientationId = viewModel.get( "detailForm.data.product.orientation.id" );

            if ( attribute?.images ) {
                const orientationMap = { "HOR": "horizontal", "VER": "vertical" };
                const targetOrientation = orientationMap[orientationId];

                if ( targetOrientation ) {

                    for ( var img of attribute.images ) {

                        if ( img.type.id == targetOrientation ) {
                            uri = img.uri;
                        }
                    }

                }
            }

            // Crea div con background impostato all'uri
            if ( uri && attribute.productItemId ) {
                const imageLayer = $( "<div>" )
                    .attr( "id", "productItem-image-" + attribute.productItemId )
                    .css( {
                        "background-image": "url('" + uri + "')",
                        "background-size": "cover",
                        "background-position": "center",
                        "position": "absolute",
                        "top": 0,
                        "left": 0,
                        "width": "100%",
                        "height": "100%",
                        "z-index": attribute.productItemId
                    } );

                // Inserisce prima di #plate-layers
                $( "#plate-layers" ).before( imageLayer );
            } else if ( uri == "" && attribute.productItemId ) {
                // Se uri è vuoto, rimuove il div se esiste
                $( "#productItem-image-" + attribute.productItemId ).remove();
            }

        },

        changeFruitImage: function( fruitId, value ) {

            if ( value?.images ) {

                var uri = value.images[0]?.uri;

                if ( uri ) {
                    pub.fruitsController.updateFruit( fruitId, { image: uri } );

                }

            }

        },

        /**
         * Renderizza i product items per un frutto.
         * @param {string} fruitId - ID del frutto
         * @param {boolean} [skipAutoTrigger=false] - Se true, non fa trigger automatico del change (per evitare loop durante caricamento)
         */
        renderProductItemsFruit: function( fruitId, skipAutoTrigger ) {
            var fruits = viewModel.get( "detailForm.data.fruits" );
            var fruit = fruits.get( fruitId );
            AP.plate.productItems.renderProductItems( {
                containerSelector: "#quotation-fruit-row-items_" + fruitId,
                attributeArray: fruit.get( "items" ).data(),
                subContainerIdPrefix: "fruit-attribute-container-",
                labelTextFn: function( item ) { return item.attributeName; },
                onSelectChange: function( selectedId, attributeId, value ) {
                    viewModel.changeFruitImage( fruitId, value );
                    viewModel.loadProductItems( selectedId, attributeId, fruitId );
                },
                skipAutoTrigger: skipAutoTrigger === true
            } );

            $( ".quotation-fruit-row[data-fruit-id=" + fruitId + "]" ).on( "mouseenter", function() {
                const color = "rgba(162, 253, 161, 0.44)";
                $( "#quotation-plate-fruits #" + fruitId ).css( "background-color", color );
                $( `div[data-fruit-id="${fruitId}"]` ).css( "background-color", "#a3fda170" );
            } ).on( "mouseleave", function() {
                $( "#quotation-plate-fruits #" + fruitId ).css( "background-color", "" );
                $( `div[data-fruit-id="${fruitId}"]` ).css( "background-color", "" );
            } );
        },

        /**
         * Renderizza i product items per la placca.
         * @param {boolean} [skipAutoTrigger=false] - Se true, non fa trigger automatico del change (per evitare loop durante caricamento)
         */
        renderProductItemsPlate: function( skipAutoTrigger ) {
            var productItems = viewModel.get( "detailForm.data.product.items" );
            AP.plate.productItems.renderProductItems( {
                containerSelector: "#quotation-plate-product-items",
                attributeArray: productItems.data(),
                subContainerIdPrefix: "attribute-container-",
                labelTextFn: function( item ) { return item.level + " " + item.attributeName; },
                onSelectChange: function( selectedId, attributeId, value ) {
                    viewModel.changeImage( value );
                    viewModel.loadProductItems( selectedId, attributeId );
                },
                skipAutoTrigger: skipAutoTrigger === true
            } );
        },

        // --- API: lines, models, finishes, load/save plate ---
        /**
         * Carica le linee (categoria 22) e apre la modale.
         * @param {function} [onLoad] - Chiamato quando le linee sono caricate (per incatenare il passo successivo in edit()).
         */
        loadLines: function( onLoad ) {
            AP.plate.api.getLines( 22, {
                done: function( xhr ) {
                    viewModel.get( "lines" ).data( xhr.data );
                    NM.util.openModal( AP.plate.fields.modalRoot );
                    applyUserPrefIfNewMode( "plate.lineId", "detailForm.data.product.line.id", "#plate-line" );
                    if ( typeof onLoad === "function" ) {
                        onLoad();
                    }
                }
            } );
        },

        /**
         * Carica i modelli per la linea selezionata.
         * @param {*} [event] - Evento (opzionale, per binding Kendo).
         * @param {function} [onDone] - Chiamato quando i modelli sono caricati (per incatenare in edit()).
         */
        loadModels: function( event, onDone ) {
            var lineId = viewModel.get( "detailForm.data.product.line.id" );
            AP.setUserPref( "plate.lineId", lineId );
            AP.plate.api.getModels( lineId, {
                done: function( xhr ) {
                    viewModel.get( "models" ).data( xhr.data );
                    applyUserPrefIfNewMode( "plate.modelId", "detailForm.data.product.model.id", "#plate-model" );
                    if ( typeof onDone === "function" ) {
                        onDone();
                    }
                }
            } );
        },

        /**
         * Carica le finiture per linea (categoria 22).
         * @param {*} [event] - Evento (opzionale, per binding Kendo).
         * @param {function} [onDone] - Chiamato quando le finiture sono caricate (per incatenare in edit()).
         */
        loadFinishes: function( event, onDone ) {
            var lineId = viewModel.get( "detailForm.data.product.line.id" );
            var modelId = viewModel.get( "detailForm.data.product.model.id" );
            AP.setUserPref( "plate.modelId", modelId );
            AP.plate.api.getFinishes( 22, lineId, {
                done: function( xhr ) {
                    viewModel.get( "finishes" ).data( xhr.data );
                    applyUserPrefIfNewMode( "plate.finishId", "detailForm.data.product.finish.id", "#plate-finish" );
                    if ( typeof onDone === "function" ) {
                        onDone();
                    }
                }
            } );
        },

        resetForm: function() {
			viewModel.set( "detailForm", defaultDetailForm );
			viewModel.set( "detailForm.data.quotationZone", AP.quotation.detail.config().zone );
		},

        // --- Save (payload = contratto server, non modificare) ---
        /**
         * Payload inviato al server (POST /manager/ajax/quotation-items/plate).
         * CONTRATTO DA MANTENERE in refactoring – non modificare struttura o nomi proprietà.
         *
         * @typedef {Object} PlateSavePayload
         * @property {string} quotationId - AP.page.quotation.id
         * @property {Object} item - viewModel.get("detailForm.data") (id, quantity, special, status, position, product, quotationZone, fruits)
         * @property {boolean} isClone - viewModel.get("detailForm.isClone")
         * @property {string} typeId - "plate"
         * @property {*} price - pricingApp().getData().data
         * @property {Object.<string, string[]>} positions - mappa fruitId -> array di cellIds occupate (es. { "uuid-1": ["cell-1","cell-2"] })
         * @property {string} imageBase64 - PNG in base64 senza prefisso data:image/png;base64,
         */
        save: function() {
            AP.loading.show();
            // Crea una mappa { id: cellIds } per ogni frutto
            var positions = {};

            pub.fruitsController.fruits.forEach( function( fruit ) {
                positions[ fruit.id ] = fruit.cellIds;
            } );

            // const parsedData =
            var status = fields.modalRoot.find( ".save-status" );
            var preview = $( "#plate-background" )[0];

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            var parsedData = {};

            parsedData.quotationId = AP.page.quotation.id;
            parsedData.item        = viewModel.get( "detailForm.data" );
            parsedData.isClone     = viewModel.get( "detailForm.isClone" );
            parsedData.typeId      = "plate";
            parsedData.price       = pricingApp().getData().data;
            parsedData.positions   = positions;
			if ( viewModel.get( "detailForm.data.quotationSubzone" ) ) {
				parsedData.item.quotationZone = viewModel.get( "detailForm.data.quotationSubzone" );
			} else if (viewModel.get("detailForm.data.quotationZone")) {
				parsedData.item.quotationZone = viewModel.get( "detailForm.data.quotationZone" );
			}

			if (viewModel.get("clone")) {
				parsedData.item.id = "";
			}

            html2canvas( preview, { useCORS: true } ).then( function( canvas ) {
                var imgData = canvas.toDataURL( "image/png" ).replace( /^data:image\/png;base64,/, "" );
                parsedData.imageBase64 = imgData;
                AP.plate.api.savePlate( parsedData, {
                    done: function( xhr ) {
                        status.html( "" );

                        AP.widget.notify( "success", "Placca salvata correttamente." );

                        resetDetailForm();

                        setTimeout( function() {
                            AP.loading.hide();
                            window.location.href = "/manager/quotations/" + parsedData.quotationId + "?tab=plate";
                        }, 1000 );
                    }
                } );
            } );

            return false;
        },

        /**
         * Carica i frutti della placca (in modifica) e li aggiunge alla griglia.
         * @param {function} [onDone] - Chiamato quando i frutti sono stati caricati (per incatenare in edit()).
         */
        loadFruits: function( onDone ) {
            var id = viewModel.get( "detailForm.data.id" );
            AP.plate.api.getPlateFruits( id, {
                done: function( xhr ) {
                    for ( var i = 0; i < xhr.data.length; i++ ) {
                        var thisFruit = xhr.data[i];
                        var newFruit = createFruit( { position: 1, fruit: thisFruit.fruit, id: thisFruit.id } );

                        viewModel.set( "currentFruit", newFruit );
                        viewModel.get( "detailForm.data.fruits" ).add( newFruit );

                        if ( thisFruit.positions && thisFruit.positions.length ) {
                            pub.fruitsController.addFruitToPositions( mapFruitForPlate( newFruit ), thisFruit.positions );
                        } else {
                            pub.fruitsController.addFruitToPlate( mapFruitForPlate( newFruit ) );
                        }

                        viewModel.addProductItemsToFruit( newFruit.id );
                    }
                    if ( typeof onDone === "function" ) {
                        onDone();
                    }
                }
            } );
        },

        onSelectFruit: function( selectedFruit ) {

            var newFruit = createFruit( { position: 1, fruit: selectedFruit } );

            viewModel.set( "currentFruit", newFruit );
            viewModel.get( "detailForm.data.fruits" ).add( newFruit );

            pub.fruitsController.addFruitToPlate( mapFruitForPlate( newFruit ) );

            viewModel.addProductItemsToFruit( newFruit.id );

        },

		visibleUpperClearButton: function() {
			const id = viewModel.get( "detailForm.data.id" );
			return id == "";
		},

        visibleLowerClearButton: function() {
            const id = viewModel.get( "detailForm.data.id" );
            return id == "";
        },

		clearFilters: function() {
			this.clearForm()
			AP.deleteUserPref( "plate.lineId" );
			AP.deleteUserPref( "plate.modelId" );
			AP.deleteUserPref( "plate.finishId" );
			this.checkCanSave();
		},

		checkCanSave: function() {
			var vm = viewModel;
			if (
				vm.get( "detailForm.data.quotationItem.quantity" ) > 0 &&
				vm.get( "detailForm.data.quotationItem.product.finish.id" ) != ""
			) {
				viewModel.set( "canSave", true );
			} else {
				viewModel.set( "canSave", false );
			}
		},

		clearForm: function() {
			var vm = viewModel
			vm.set("detailForm.data.product.line.id", "");
			vm.set("detailForm.data.product.finish.id", "");
			vm.set("detailForm.data.product.model.id", "");
		},
    } );

	viewModel.bind("change", function (e) {
		if (e.field === "detailForm.data.quotationZone") {
			const quotationZone = viewModel.get("detailForm.data.quotationZone");
			viewModel.loadSubZones(quotationZone);
		}
	});

    pub.new = function( onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        console.log( "new:zone", AP.quotation.detail.config().zone );

        resetDetailForm();

        viewModel.set( "detailForm.data.quotationZone", AP.quotation.detail.config().zone );
        viewModel.set( "isEditMode", false );

        pricingApp().init( "plate", undefined );

        initFruitsSuggest();
        initPositionSuggest();

        viewModel.loadLines();

    };

    /**
     * Apre la modale in modifica (o duplica) per la placca con id dato.
     * Carica i dati dal server e popola linee → modelli → finiture → product items → placca → frutti
     * in catena, senza delay artificiali.
     * @param {Object} opts
     * @param {string} opts.id - ID quotation item placca
     * @param {function} [opts.onSave] - Callback dopo salvataggio
     * @param {boolean} [opts.clone=false] - Se true, titolo "Duplica placca"
     */
    pub.edit = function( { id, onSave, clone = false } ) {
        window.location.hash = "plate/" + id;
        resetDetailForm();
        viewModel.set( "isEditMode", true );
        viewModel.set( "detailForm.isClone", clone );
        viewModel.set( "detailForm.title", clone ? "Clona placca" : "Modifica placca" );

        AP.plate.api.getPlate( id, {
            done: function( xhr ) {
				viewModel.populateProduct( xhr.data.quotationItem.product );
                viewModel.set( "detailForm.data.id", xhr.data.quotationItem.id );
                viewModel.set( "detailForm.data.position", xhr.data.quotationItem.position );
                viewModel.set( "detailForm.data.note", xhr.data.quotationItem.note );
                viewModel.set( "detailForm.data.quantity", xhr.data.quotationItem.quantity );

                const quotationZone = xhr.data.quotationItem.quotationZone
                if ( quotationZone ) {
                    if (quotationZone.origin) {
                        viewModel.set( "detailForm.data.quotationZone", xhr.data.quotationItem.quotationZone.origin );
                        viewModel.set( "detailForm.data.quotationSubzone", xhr.data.quotationItem.quotationZone );
                    } else {
                        viewModel.set( "detailForm.data.quotationZone", xhr.data.quotationItem.quotationZone );
                    }
                }
                // viewModel.set( "detailForm.data.product.orientation", xhr.data.quotationItem.frame.orientation );

                initFruitsSuggest();
                initPositionSuggest();

                // Catena di caricamento senza delay artificiali: ogni passo chiama il successivo nel suo callback.
                viewModel.loadLines( function() {
                    viewModel.loadModels( undefined, function() {
                        viewModel.loadFinishes( undefined, function() {
                            viewModel.firstLoadProductItems().then( function() {
                                var platePromise = viewModel.loadPlate( xhr.data.quotationItem.frame.orientation );
                                AP.loading.hide();
                                if ( platePromise && typeof platePromise.then === "function" ) {
                                    platePromise.then( function() {
                                        viewModel.loadFruits();
                                    } );
                                } else {
                                    viewModel.loadFruits();
                                }
                            } );
                        } );
                    } );
                } );

                pricingApp().init( "plate", { data: xhr.data.quotationItem.price } );
            }
        } );

        if (clone) {
            $('#saveButton').css("display", "none")
            $('#cloneButton').css("display", "block")
        } else {
            $('#saveButton').css("display", "block")
            $('#cloneButton').css("display", "none")
        }
    };

    var initPositionSuggest = function() {

        console.log( "initPositionSuggest" );

        var suggest = $( "#qt-plate-position-suggest" );
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

        console.log( "new:zone initPositionSuggest", viewModel.get( "detailForm.data.quotationZone" ) );

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
                        url: "/manager/ajax/quotations/zones/" + viewModel.get( "detailForm.data.quotationZone.id" ) + "/positions",
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

            change: function( event ) {

                var value = this.value();
                // var exists = false;

                // Verifichiamo se l'elemento è presente nel DataSource
                var exists = this.dataSource.data().find( item => item.code === value );

                if ( !exists ) {
                    var position = { id: "", code: value };
                    viewModel.set( "detailForm.data.position", position );
                }
            },

            select: function( event ) {
                var position = this.dataItem( event.item.index() );
                viewModel.set( "detailForm.data.position", position );
            }
        } );

    };

    var initFruitsSuggest = function() {

        var suggest = $( "#plate-fruit-suggest" );
        var autocomplete = suggest.data( "kendoAutoComplete" );
        var suggestTemplate = $( "#quotation-fruit-suggest-row-tmpl" ).html();

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
            minLength: 3,
            dataSource: new kendo.data.DataSource( {
                serverFiltering: true,
                transport: {
                    read: {
                        url: "/manager/ajax/fruits",
                        data: {
                            str: function() {
                                return suggest.data( "kendoAutoComplete" ).value();
                            },
                        },
                    },
                    parameterMap: function( data, type ) {
                        if ( type === "read" ) {
                            return { "str": data.str(), "lineId": viewModel.get( "detailForm.data.product.line.id" ) };
                        }
                    }
                },
                schema: {
                    data: function( xhr ) {
                        return xhr.data;
                    }
                },
            } ),
            select: function( event ) {
                var item = this.dataItem( event.item.index() );

                viewModel.onSelectFruit( item );
            },
            noDataTemplate: "<div>NESSUN RECORD</div>"
        } );

    };

    pub.init = async function( setup ) {

        settings.container = setup.container;

        kendo.bind( settings.container, viewModel );

		viewModel.loadZones();

        // document.getElementById( "contact" ).classList.add( "active" );

        // TODO: Attiva il primo tab ogni volta che
        // la modale viene aperta. Bisognerebbe capire perchè
        settings.container.on( "shown.bs.modal", function() {
            setTimeout( function() {

                // Forza l'attivazione del primo tab manipolando direttamente le classi
                $( "#plate-product-items-tab" ).addClass( "show active" );
                $( "#plate-fruit-product-items-tab" ).removeClass( "show active" );

                $( "#plate-product-items-but" ).addClass( "active" );
                $( "#plate-fruit-product-items-but" ).removeClass( "active" );
            }, 50 );
        } );
    };

    pub.getItem = function() {
        return viewModel.get( "detailForm.data" );
    };

	pub.clone = function({ clone, id }) {
		pub.edit({ id, clone })
	}

    return pub;
}() );
