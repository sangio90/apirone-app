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
        // data: { position: 1, fruit: { id: "", name: "" }, items: [] }

        var fruit = data;

        // Genera ID univoco per questa istanza
        fruit.id = NM.util.uuid();
        fruit.fruitId = data.fruit.id; // ID del prodotto frutto originale

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
    var defaultDetailForm = {
        data: {
            // quotationItemId: "",
            id: "",
            quantity: 1,
            // price: 0,
            special: false,
            status: {
                id: "ACT"
            },
            position: {
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
            quotationZone: {
                id: ""
            },
            fruits: new kendo.data.DataSource( { // es. data: { position: 1, { fruit: { id: , name: } } }
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

    // --- ViewModel (Kendo ObservableObject) ---
    var viewModel = new kendo.data.ObservableObject( {

        detailForm: defaultDetailForm,

        lines: new kendo.data.DataSource(),
        models: new kendo.data.DataSource(),
        finishes: new kendo.data.DataSource(),

        plate: defaultPlate,
        availableOrientations: [],

        currentFruit: {},

        toggleFruitsLabel: "Comprimi tutti",

        isEditMode: false,

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
            // console.log( "changeOrientation:event", event );

            var orientationId = this.get( "detailForm.data.product.orientation.id" );

            var frameId = viewModel.get( "detailForm.data.product.frame.id" );
            var productId = viewModel.get( "detailForm.data.product.id" );

            // console.log( "frameId", frameId );
            // console.log( "productId", productId );

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

        loadPlate: function() {

            // id from model
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
                    viewModel.set( "plate.id", xhr.data.id );
                    viewModel.set( "plate.code", xhr.data.code );
                    viewModel.set( "plate.width", xhr.data?.width ?? 1200 );
                    viewModel.set( "plate.height", xhr.data?.height ?? 500 );
                    viewModel.set( "plate.orientation", xhr.data.orientation );
                    viewModel.set( "detailForm.data.product.orientation", xhr.data.orientation );
                    viewModel.set( "plate.cellOrientation", xhr.data.cellOrientation );
                    viewModel.set( "availableOrientations", xhr.data.availableOrientations );
                    viewModel.set( "plate.grid", xhr.data.grid );
                    viewModel.set( "plate.image", image );
                    viewModel.set( "plate.grid", xhr.data.grid );
                    configPlate();
                }
            } );

        },

        firstLoadProductItems: function( type ) {
            const quotationItemId = viewModel.get( "detailForm.data.id" );
            const productId = viewModel.get( "detailForm.data.product.id" );

            // console.log( "firstLoadProductItems:productId", productId );

            AP.plate.api.getProductItems( productId, null, {
                done: function( xhr ) {

                        // console.log( "firstLoadProductItems:xhr.data", xhr.data );

                        // var userItems = AP.getUserPref( "plate.product.items" );

                        // console.log( "xhr.count", xhr.count );

                        if ( xhr.count > 0 ) {

                            if ( xhr.data[0].horizontalImage ) {
                                var image = xhr.data[0].horizontalImage;
                            } else {
                                var image = xhr.data[0].verticalImage;
                            }

                            if ( !viewModel.get( "detailForm.data.product.image" ) && image ) {

                                viewModel.set( "detailForm.data.product.image", image );
                                viewModel.set( "backgroundImage", image );
                                viewModel.set( "backgroundImage.url", "url('" + image.uri + "')" );
                            }

                            viewModel.set( "detailForm.data.product.items", new kendo.data.DataSource() );

                            var productItems = viewModel.get( "detailForm.data.product.items" );

                            var attributeArray = productItems.data();

                            // settiamo nel viewModel tutte le select di level 0 e le popoliamo con tutte le options
                            xhr.data.forEach( item => {
                                const existing = attributeArray.find( d => d.attributeId === item.attribute.id );

                                // console.log( "existing:item", item );

                                if ( existing ) {
                                    if ( !existing.values.find( v => v.productItemId === item.id ) ) {

                                        existing.values.push( {
                                            attributeValue: item.attributeValue,
                                            productItemId: item.id,
                                            images: item.images,
                                            // parentAttributeId: null,
                                            selected: false
                                        } );

                                        productItems.trigger( "change" );
                                    }
                                } else {

                                    const parsedData = {
                                        attributeId: item.attribute.id,
                                        attributeName: item.attribute.name,

                                        // parentAttributeId: null,
                                        level: 0,
                                        values: [
                                            {
                                                attributeValue: item.attributeValue,
                                                productItemId: item.id,
                                                images: item.images,
                                                selected: false
                                            }
                                        ]
                                    };

                                    productItems.add( parsedData );
                                }
                            } );

                            viewModel.renderProductItemsPlate();

                            setTimeout( function() {

                                viewModel.loadPlate();

                            }, 500 );

                        }
                    }
                } ).then( async function() {
                if ( quotationItemId.length ) {
                    await AP.plate.api.getQuotationItemProductItems( quotationItemId, {
                        done: async function( xhr ) {
                            xhr.data.sort( ( a, b ) => a.productItem.orderby - b.productItem.orderby );
                            if ( xhr.data.length > 0 ) {
                                for ( const qipi of xhr.data ) {
                                    const select = $( "select[data-attribute-id=\"" + qipi.productItem.attribute.id + "\"]" );
                                    if ( select.length > 0 ) {
                                        select.val( qipi.productItem.id );
                                        await viewModel.loadProductItems( qipi.productItem.id, qipi.productItem.attribute.id );
                                    }
                                }
                            }
                        }
                    } );
                }
            } );
        },

        loadProductItems: function( originId, attributeId, fruitId ) {

            if ( fruitId == undefined ) {
                var type = "plate";
                var product = viewModel.get( "detailForm.data.product" );
                var productItems = viewModel.get( "detailForm.data.product.items" );
                var prodyctIdForCall = product.get( "id" );
            } else {
                var type = "fruit";
                var fruits = viewModel.get( "detailForm.data.fruits" );
                var product = fruits.get( fruitId );

                var productItems = product.get( "items" );
                var prodyctIdForCall = product.get( "fruit.id" );

            }

            var productId = product.get( "id" );
            const attributeArray = productItems.data();
            var originId = originId || "";

            // Deselezionamento: originId vuoto
            if ( originId == "" ) {

                // console.log( "qui:originId vuoto" );

                var actualIndex = null;

                for ( let i = attributeArray.length - 1; i >= 0; i-- ) {
                    if ( attributeArray[i].attributeId === attributeId ) {
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

                viewModel.renderProductItemsPlate();

                // resolve();
                return;
            }

            // Selezionamento: originId valorizzato
            AP.plate.api.getProductItems( prodyctIdForCall, originId || undefined, {
                done: function( xhr ) {

                        if ( xhr.data.length > 0 ) {

                            let attribute = null;
                            let toInsert = false;
                            let parentIndex = -1;

                            // Trovo l'indice dell'attributo selezionato
                            attributeArray.forEach( ( d, idx ) => {
                                if ( d.attributeId == attributeId ) {
                                    parentIndex = idx;
                                }
                            } );

                            // Rimuovo eventuali attributi figli
                            const i = parentIndex + 1;

                            // console.log( "attributeArray.parentIndex", attributeArray[parentIndex] );

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
                                    attributeId: xhr.data[0].attribute.id,
                                    attributeName: xhr.data[0].attribute.name,
                                    // parentAttributeId: attributeId,
                                    level: attributeArray[parentIndex].level + 1,
                                    values: []
                                };
                                toInsert = true;
                            }

                            // Imposto selected sul parent
                            if ( parentIndex !== -1 ) {
                                const parent = productItems.at( parentIndex );
                                parent.get( "values" ).forEach( value => {
                                    value.selected = value.productItemId == originId;
                                } );
                            }

                            // Popolo i valori del nuovo attributo
                            xhr.data.forEach( function( item ) {
                                attribute.values.push( {
                                    attributeValue: item.attributeValue,
                                    productItemId: item.id,
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
                                if ( d.attributeId == attributeId ) {
                                    parentIndex = idx;
                                }
                            } );

                            if ( parentIndex !== -1 ) {
                                const parent = productItems.at( parentIndex );
                                parent.get( "values" ).forEach( v => {
                                    v.selected = v.productItemId == originId;
                                } );
                            }
                        }

                        // console.log( "loadProductItems:afterLoading:type", type );

                        if ( type == "plate" ) {
                            // console.log( "renderProductItemsPlate" );
                            viewModel.renderProductItemsPlate();
                        } else {
                            // console.log( "renderProductItemsFruit" );
                            viewModel.renderProductItemsFruit( productId );
                        }

                        // Recupera tutti i select con classe "select-item" e aggancia calculatePriceItem
                        var selects = $( "select.select-item" );
                        // console.log( "select:lenght", selects.length );

                        $( "select.select-item" ).each( function() {
                            // console.log( "change.calculatePrice:before" );
                            $( this ).off( "change.calculatePrice" ).on( "change.calculatePrice", function() {
                                // console.log( "change.calculatePrice:after" );
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

        loadProduct() { // triggered by onchange event on finishId field

            var lineId = viewModel.get( "detailForm.data.product.line.id" );
            var modelId = viewModel.get( "detailForm.data.product.model.id" );
            var finishId = viewModel.get( "detailForm.data.product.finish.id" );

            AP.setUserPref( "plate.finishId", finishId );

            AP.plate.api.getProductByParams( 22, lineId, modelId, finishId, {
                done: function( xhr ) {
                    viewModel.populateProduct( xhr.data );
                    viewModel.firstLoadProductItems();
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
                var quotationItemId = viewModel.get( "detailForm.data.id" );
                if ( quotationItemId && quotationItemId !== "" ) {
                    await AP.plate.api.getQuotationItemProductItems( quotationItemId, {
                        done: async function( xhr ) {
                            xhr.data.sort( function( a, b ) { return a.productItem.orderby - b.productItem.orderby; } );
                            if ( xhr.data.length > 0 ) {
                                for ( var qi = 0; qi < xhr.data.length; qi++ ) {
                                    var qipi = xhr.data[qi];
                                    var sel = $( "select[data-attribute-id=\"" + qipi.productItem.attribute.id + "\"]" );
                                    if ( sel.length > 0 ) {
                                        sel.val( qipi.productItem.id );
                                        await viewModel.loadProductItems( qipi.productItem.id, qipi.productItem.attribute.id, fruitId );
                                    }
                                }
                            }
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

        renderProductItemsFruit: function( fruitId ) {
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
                }
            } );
        },

        renderProductItemsPlate: function() {
            var productItems = viewModel.get( "detailForm.data.product.items" );
            AP.plate.productItems.renderProductItems( {
                containerSelector: "#quotation-plate-product-items",
                attributeArray: productItems.data(),
                subContainerIdPrefix: "attribute-container-",
                labelTextFn: function( item ) { return item.level + " " + item.attributeName; },
                onSelectChange: function( selectedId, attributeId, value ) {
                    viewModel.changeImage( value );
                    viewModel.loadProductItems( selectedId, attributeId );
                }
            } );
        },

        // --- API: lines, models, finishes, load/save plate ---
        loadLines: function( onLoad ) {
            AP.plate.api.getLines( 22, {
                done: function( xhr ) {
                    viewModel.get( "lines" ).data( xhr.data );
                    NM.util.openModal( AP.plate.fields.modalRoot );
                    applyUserPrefIfNewMode( "plate.lineId", "detailForm.data.product.line.id", "#plate-line" );
                    if ( onLoad !== undefined ) {
                        onLoad();
                    }
                }
            } );
        },

        loadModels: function( event ) {
            var lineId = viewModel.get( "detailForm.data.product.line.id" );
            AP.setUserPref( "plate.lineId", lineId );
            AP.plate.api.getModels( lineId, {
                done: function( xhr ) {
                    viewModel.get( "models" ).data( xhr.data );
                    applyUserPrefIfNewMode( "plate.modelId", "detailForm.data.product.model.id", "#plate-model" );
                }
            } );
        },

        loadFinishes: function( event ) {
            var lineId = viewModel.get( "detailForm.data.product.line.id" );
            var modelId = viewModel.get( "detailForm.data.product.model.id" );
            AP.setUserPref( "plate.modelId", modelId );
            AP.plate.api.getFinishes( 22, lineId, {
                done: function( xhr ) {
                    viewModel.get( "finishes" ).data( xhr.data );
                    applyUserPrefIfNewMode( "plate.finishId", "detailForm.data.product.finish.id", "#plate-finish" );
                }
            } );
        },

        resetForm: function() { },

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

            // Crea una mappa { id: cellIds } per ogni frutto
            var positions = {};

            pub.fruitsController.fruits.forEach( function( fruit ) {
                positions[ fruit.id ] = fruit.cellIds;
            } );

            console.log( "save:positions", positions );

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

            html2canvas( preview, { useCORS: true } ).then( function( canvas ) {
                var imgData = canvas.toDataURL( "image/png" ).replace( /^data:image\/png;base64,/, "" );
                parsedData.imageBase64 = imgData;
                AP.plate.api.savePlate( parsedData, {
                    done: function( xhr ) {
                        status.html( "" );
                        AP.widget.notify( "success", "Placca salvata correttamente." );
                        viewModel.set( "detailForm", defaultDetailForm );
                    }
                } );
            } );

            return false;
        },

        loadFruits: function() {
            var id = viewModel.get( "detailForm.data.id" );
            AP.plate.api.getPlateFruits( id, {
                done: function( xhr ) {
                    for ( var i = 0; i < xhr.data.length; i++ ) {
                        var thisFruit = xhr.data[i];
                        var newFruit = createFruit( { position: 1, fruit: thisFruit.fruit } );
                        viewModel.set( "currentFruit", newFruit );
                        viewModel.get( "detailForm.data.fruits" ).add( newFruit );
                        pub.fruitsController.addFruitToPlate( mapFruitForPlate( newFruit ) );
                        viewModel.addProductItemsToFruit( newFruit.id );
                    }
                }
            } );
        },

        onSelectFruit: function( selectedFruit ) {

            var newFruit = createFruit( { position: 1, fruit: selectedFruit } );

            viewModel.set( "currentFruit", newFruit );
            viewModel.get( "detailForm.data.fruits" ).add( newFruit );

            // console.log( "pub.fruitsController", pub.fruitsController );

            // console.log( "newFruit", newFruit );

            pub.fruitsController.addFruitToPlate( mapFruitForPlate( newFruit ) );

            viewModel.addProductItemsToFruit( newFruit.id );

        },

    } );

    pub.new = function( onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        console.log( "new:zone", AP.quotation.detail.config().zone );

        viewModel.set( "detailForm", defaultDetailForm );
        viewModel.set( "detailForm.data.quotationZone", AP.quotation.detail.config().zone );
        viewModel.set( "isEditMode", false );

        pricingApp().init( "plate", undefined );

        initFruitsSuggest();
        initPositionSuggest();

        viewModel.loadLines();

    };

    pub.edit = function( { id, onSave, clone = false } ) {

        console.log( "edit" );

        // Aggiorna URL hash per checkUrlHash()
        window.location.hash = "plate/" + id;

        viewModel.set( "detailForm", defaultDetailForm );
        viewModel.set( "isEditMode", true );

        viewModel.set( "detailForm.isClone", clone );


        if ( clone ) {
            viewModel.set( "detailForm.title", "Duplica placca" );
        } else {
            viewModel.set( "detailForm.title", "Modifica placca" );
        }

        AP.plate.api.getPlate( id, {
            done: function( xhr ) {
                viewModel.populateProduct( xhr.data.quotationItem.product );
                viewModel.set( "detailForm.data.id", xhr.data.quotationItem.id );
                viewModel.set( "detailForm.data.quotationZone", xhr.data.quotationItem.quotationZone );

                var delay = function( ms ) { return new Promise( function( resolve ) { setTimeout( resolve, ms ); } ); };

                viewModel.loadLines();

                    async function loadAll() {

                        await delay( 200 );
                        viewModel.loadModels();

                        await delay( 200 );
                        viewModel.loadFinishes();

                        await delay( 200 );
                        viewModel.firstLoadProductItems();

                        await delay( 200 );
                        await viewModel.loadPlate();

                        await delay( 200 );
                        // loop on fruits
                        // viewModel.addProductItemsToFruit();
                        console.log( "loadFruits" );
                        viewModel.loadFruits();

                    }

                    loadAll();

                    initFruitsSuggest();
                    initPositionSuggest();

                }
            } );

    };

    var initPositionSuggest = function() {

        console.log( "suggest:", viewModel.get( "detailForm.data.quotationZone" ) );

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
            /*
            change: function( e ) {
                var value = this.value();
                var exists = false;

                // Verifichiamo se l'elemento è presente nel DataSource
                var dataItem = this.dataSource.data().find( item => item.Name === value );

                if ( !dataItem ) {
                    console.log( "suggest:Inserito nuovo elemento:", value );
                    // Qui puoi gestire la logica per i nuovi elementi
                    // Magari aprendo una modale o preparando una chiamata Ajax
                } else {
                    console.log( "suggest:Elemento selezionato dalla lista:", dataItem );
                }
            },
            */
            noDataTemplate: false,
            select: function( event ) {
                var item = this.dataItem( event.item.index() );
                // console.log( "suggest:Inserito nuovo elemento:", item );
            },
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

    pub.init = function( setup ) {

        settings.container = setup.container;

        kendo.bind( settings.container, viewModel );

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

    return pub;
}() );
