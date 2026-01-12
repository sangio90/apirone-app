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

    const {
        constants,
        orientation,
        CELL_TYPE,
        Plate,
        Cell,
        Fruit,
        FruitsController
    } = gridModule;

    // Maintain access to fields for UI interaction parts
    const fields = AP.plate.fields;

    var pub = {
        fruitsController: null,
    };

    const settings = {
        container: null,
    };

    var mapFruitForPlate = function( data ) {

        var fruit = {
            id: data.id,
            fruitId: data.fruit.id,
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
        if ( !data.id ) {
            data.id = NM.util.uuid();
        }

        var fruit = data;

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

        // var plate = this.plates.get( this.get( "plate" ) );
        var plate = viewModel.get( "plate" );

        //plate.orientation.id = "VER"; // for test
        //plate.orientationCell.id = "VER"; // for test

        let freeCellWidth = constants.GRID_CELL_DIMENSIONS[gridModule.CELL_TYPE.FREE].width;
        let freeCellHeight = constants.GRID_CELL_DIMENSIONS[gridModule.CELL_TYPE.FREE].height;

        console.log("configPlate:CELL_TYPE.FREE", gridModule.CELL_TYPE.FREE)
        console.log("configPlate:plate.orientationCell.id", plate.orientationCell.id)
        console.log("configPlate:orientation.VERTICAL", orientation.VERTICAL)

        if ( plate.orientationCell.id == orientation.VERTICAL ) {
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
                const cellType = plate.grid[iRow][iCol];

                const cell = new Cell(
                    constants.GRID_CELL_DIMENSIONS[cellType].width,
                    constants.GRID_CELL_DIMENSIONS[cellType].height,
                    plate.orientationCell.id,
                    cellType,
                );

                row.push( cell );
            }

            grid.push( row );
        }

        const plateObj = new Plate( {
            width: plate.width,
            height: plate.height,
            orientation: plate.orientation.id,
            cellOrientation: plate.orientationCell.id,
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

    var defaultDetailForm = {
        data: {
            // quotationItemId: "",
            id: "",
            quantity: 1,
            price: 0,
            product: {
                orientation: {
                    id: "HOR"
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
            status: {
                id: "ACT",
                name: ""
            },
            selectedOrientation: {
                id: "HOR"
            },
            fruits: new kendo.data.DataSource( { // es. data: { position: 1, { fruit: { id: , name: } } }
                data: [],
                schema: {
                    model: { id: "id" }
                }
            } )
        },
        // statuses: AP.page.statuses,
        title: "Carica placca",
        canSave: false,
        isClone: false,
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
            id: "HOR"
        },
        orientationCell: {
            id: "HOR"
        },
        grid: [
            // LEGEND:
            // "_" - empty free space
            // "0" - prohibited space
            [
                "_",
                "_",
            ],
        ],
    };

    var viewModel = new kendo.data.ObservableObject( {

        detailForm: defaultDetailForm,
        lines: new kendo.data.DataSource(),
        models: new kendo.data.DataSource(),
        finishes: new kendo.data.DataSource(),

        plate: defaultPlate,
        availableOrientations: [],

        currentFruit: {},

        toggleFruitsLabel: "Comprimi tutti",

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        getFruitCount() {
            return this.get( "detailForm.data.fruits" ).total();
        },

        removeFruit( event ) {

            viewModel.get( "detailForm.data.fruits" ).remove( event.data );
            pub.fruitsController.removeFruit( event.data.id );

        },

        toggleFruit( event ) {
            event.data.set( "expanded", !event.data.get( "expanded" ) );
        },

        changeOrientation( event ) {
            console.log("changeOrientation:event", event);

            var orientationId = this.get( "detailForm.data.product.orientation.id" );

            console.log("orientationId", orientationId);
            
            var frameId = viewModel.get( "detailForm.data.product.frame.id" );
            var productId = viewModel.get( "detailForm.data.product.id" );
            
            console.log("frameId", frameId)
            console.log("productId", productId)

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/frames/" + frameId + "?orientation=" + orientationId + "&productId=" + productId,
                callback: {
                    done: function( xhr ) {

                        viewModel.set( "plate.orientation", xhr.data.orientation );
                        viewModel.set( "plate.grid", xhr.data.grid );

                        console.log("xhr.data.image", xhr.data.image)

                        viewModel.set( "plate.image", xhr.data.image ); // by product

                        configPlate();

                    }
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

            console.log("frame", frame);

            var frameId = frame.id;

            this.set( "detailForm.data.product.frame.id", frameId );

            return NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/frames/" + frameId,
                callback: {
                    done: function( xhr ) {

                        viewModel.set( "plate.id", xhr.data.id );
                        viewModel.set( "plate.code", xhr.data.code );
                        viewModel.set( "plate.width", xhr.data?.width ?? 1200 );
                        viewModel.set( "plate.height", xhr.data?.height ?? 500 );
                        viewModel.set( "plate.orientation", xhr.data.orientation );
                        viewModel.set( "plate.cellOrientation", xhr.data.cellOrientation );
                        viewModel.set( "availableOrientations", xhr.data.availableOrientations );
                        viewModel.set( "plate.grid", xhr.data.grid );

                        viewModel.set( "plate.image", image ); // by product
                        viewModel.set( "plate.grid", xhr.data.grid );

                        configPlate();

                    }
                }
            } );

        },

        firstLoadProductItems: function( type ) {
            const quotationItemId = viewModel.get( "detailForm.data.id" );
            const productId = viewModel.get( "detailForm.data.product.id" );

            // Chiamata AJAX iniziale per ottenere tutti i product items
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/product-items?productId=" + productId,
                callback: {
                    done: function( xhr ) {

                        console.log( "firstLoadProductItems:xhr.data", xhr.data );

                        var userItems = AP.getUserPref( "plate.product.items" );

                        console.log( "xhr.count", xhr.count );

                        if ( xhr.count > 0 ) {

                            if ( !viewModel.get( "detailForm.data.product.image" ) && xhr.data[0].horizontalImage ) {
                                viewModel.set( "detailForm.data.product.image", xhr.data[0].horizontalImage );
                                viewModel.set( "backgroundImage", xhr.data[0].horizontalImage );
                                viewModel.set( "backgroundImage.url", "url('" + xhr.data[0].horizontalImage.uri + "')" );
                            }

                            if ( quotationItemId != "" || !userItems || userItems.length == 0 ) {
                                viewModel.set( "detailForm.data.product.items", new kendo.data.DataSource() );
                            } else {
                                if ( quotationItemId == "" ) {
                                    const itemsDataSource = new kendo.data.DataSource( {
                                        data: userItems
                                    } );
                                    viewModel.set( "detailForm.data.product.items", itemsDataSource );
                                    viewModel.get( "detailForm.data.product.items" ).read();
                                    viewModel.renderProductPreview( viewModel.get( "detailForm.data.product.items" ) );
                                }
                            }

                            var productItems = viewModel.get( "detailForm.data.product.items" );

                            var attributeArray = productItems.data();

                            // settiamo nel viewModel tutte le select di level 0 e le popoliamo con tutte le options
                            xhr.data.forEach( item => {
                                const existing = attributeArray.find( d => d.attributeId === item.attribute.id );
                                if ( existing ) {
                                    if ( !existing.values.find( v => v.productItemId === item.id ) ) {

                                        existing.values.push( {
                                            attributeValue: item.attributeValue,
                                            productItemId: item.id,
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
                }
            } ).then( async function() {

                console.log( "selected" );

                // Se ci sono quotation items pre-selezionati, li carichiamo
                if ( quotationItemId.length ) {
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
                                            console.log( "ricorsivamente" );
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

        loadProductItems: function( originId, attributeId, fruitId ) {

            // return new Promise( ( resolve, reject ) => {

            if ( fruitId == undefined ) {
                var type = "plate";
                var productId = viewModel.get( "detailForm.data.product.id" );
                var prodyctIdForCall = productId;
                var productItems = viewModel.get( "detailForm.data.product.items" );
            } else {
                var type = "fruit";
                var fruits = viewModel.get( "detailForm.data.fruits" );
                var fruit = fruits.get( fruitId );

                console.log( "loadProductItems:fruit", fruit );

                var productId = fruit.get( "id" );
                var productItems = fruit.get( "items" );
                var prodyctIdForCall = fruit.get( "fruit.id" );
            }

            //console.log( "type", type );

            const attributeArray = productItems.data();

            var originId = originId || "";

            let url = "/manager/ajax/product-items?productId=" + prodyctIdForCall;

            // TODO: check if they are not all with the originId
            if ( originId ) {
                url += "&originId=" + originId;
            }

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
                                if ( d.attributeId == attributeId ) { parentIndex = idx; }
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

                            console.log( "att", xhr.data[0].attribute.name );

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
                                parent.get( "values" ).forEach( v => {
                                    v.selected = v.productItemId == originId;
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

                        // resolve();

                    },
                }
            } );

            // } );

        },

        populateProduct( product ) { // without items

            // console.log( "populateProduct", product );

            viewModel.set( "detailForm.data.product.id", product?.id ); // "" = nuovo
            viewModel.set( "detailForm.data.product.finish.id", product.finish.id );
            viewModel.set( "detailForm.data.product.model.id", product.model.id );
            viewModel.set( "detailForm.data.product.model.code", product.model.code ); // for frame
            viewModel.set( "detailForm.data.product.line.id", product.line.id );
            viewModel.set( "detailForm.data.product.image.id", product?.horizontalImage?.id );
            viewModel.set( "detailForm.data.product.image.uri", product?.horizontalImage?.uri );

        },

        loadProduct() { // triggered by onchange event on finishId field

            console.log( "loadProduct" );

            var lineId = viewModel.get( "detailForm.data.product.line.id" );
            var modelId = viewModel.get( "detailForm.data.product.model.id" );
            var finishId = viewModel.get( "detailForm.data.product.finish.id" );

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotation-items/product/by-params" +
                    "?categoryId=22" +
                    "&lineId=" + lineId +
                    "&modelId=" + modelId +
                    "&finishId=" + finishId,
                callback: {
                    done: function( xhr ) {

                        // console.log( "loadProduct:populate", xhr.data );

                        viewModel.populateProduct( xhr.data );

                        // set items
                        viewModel.firstLoadProductItems();

                    }
                }
            } );

        },

        addProductItemsToFruit: function( fruitId ) {

            var fruits = viewModel.get( "detailForm.data.fruits" );
            var thisFruit = fruits.get( fruitId );
            var productId = thisFruit.fruit.id;

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/product-items?productId=" + productId,
                callback: {
                    done: function( xhr ) {

                        if ( xhr.count > 0 ) {

                            var thisImage = xhr.data[0].horizontalImage;

                            // Overwrite the product image if the item image exists
                            if ( thisImage ) {
                                thisFruit.set( "fruit.horizontalImage", thisImage );
                                pub.fruitsController.updateFruit( thisFruit.id, { image: thisImage.uri } );
                            }

                            var fruitItems = thisFruit.get( "items" );
                            var attributeArray = fruitItems.data();

                            xhr.data.forEach( function( item ) {

                                const attributeExisting = attributeArray.find( d => d.attributeId === item.attribute.id );

                                if ( attributeExisting ) {

                                    attributeExisting.values.push( {
                                        attributeValue: item.attributeValue,
                                        productItemId: item.id,
                                        selected: false
                                    } );

                                } else {

                                    const itemAndValues = {
                                        attributeId: item.attribute.id,
                                        attributeName: item.attribute.name,
                                        level: 0,
                                        values: [
                                            {
                                                attributeValue: item.attributeValue,
                                                productItemId: item.id,
                                                selected: false
                                            }
                                        ]
                                    };

                                    fruitItems.add( itemAndValues );

                                }

                            } );

                            console.log( "fruitItems", fruitItems );

                            thisFruit.set( "items", fruitItems );

                            viewModel.renderProductItemsFruit( fruitId );

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

        renderProductItemsFruit: function( fruitId ) {
            const container = $( "#quotation-fruit-row-items_" + fruitId );

            container.empty();

            // console.log( "fruit:container:id", fruitId );
            // console.log( "fruit:container", container );

            var fruits = viewModel.get( "detailForm.data.fruits" );
            var fruit = fruits.get( fruitId );

            const attributeArray = fruit.get( "items" ).data();

            // console.log( "fruit:attributeArray", fruitId, attributeArray );

            attributeArray.forEach( function( item ) {

                var newLevel = ( 1.5 * item.level ) + "rem";

                // console.log( "renderProductItemsFruit:attributeArray:item", item );

                const attrName = item.attributeName;
                const values = item.values;

                const subContainer = $( "<div>" );
                subContainer.attr( "id", "fruit-attribute-container-" + item.attributeId );
                container.append( subContainer );

                const label = $( "<label>" );

                label.addClass( "mb-1" );
                label.css( "margin-left", newLevel );
                // label.text( item.level + " " + attrName );
                label.text( attrName );
                subContainer.append( label );

                const select = $( "<select>" ).addClass( "form-control me-3 mb-2" ).on( "change", function() {
                    const selectedId = $( this ).val();
                    const attributeId = $( this ).data( "attribute-id" );
                    viewModel.loadProductItems( selectedId, attributeId, fruitId );
                } );

                select.attr( "data-attribute-id", item.attributeId );

                if ( item.level > 0 ) {
                    select.css( "margin-left", newLevel );
                    select.css( "width", `calc(100% - ${1.5 * item.level}rem)` );
                }

                values.forEach( function( attrValue ) {
                    const option = $( "<option>" )
                        .val( attrValue.productItemId )
                        // .html( `<b>${attrName}</b> ${attrValue.attributeValue.rawValue.name}` );
                        .html( `${attrValue.attributeValue.rawValue.name}` );
                    select.append( option );
                } );

                // Imposto la option selezionata
                const selectedOption = values.find( attrValue => attrValue.selected === true );
                if ( selectedOption ) {
                    if ( selectedOption ) {
                        select.val( selectedOption.productItemId );
                    }
                } else {
                    select.prop( "selectedIndex", 0 ).trigger( "change" );
                }

                subContainer.append( select );
            } );
        },

        renderProductItemsPlate: function() {
            const container = $( "#quotation-plate-product-items" );
            container.empty();

            const productItems = viewModel.get( "detailForm.data.product.items" );
            const attributeArray = productItems.data();

            attributeArray.forEach( function( item ) {
                const attrName = item.attributeName;
                const values = item.values;

                const subContainer = $( "<div>" );
                subContainer.attr( "id", "attribute-container-" + item.attributeId );
                container.append( subContainer );

                const label = $( "<label>" );
                label.addClass( "mb-1" );
                label.css( "margin-left", ( 1.5 * item.level ) + "rem" );
                label.text( item.level + " " + attrName );
                subContainer.append( label );

                const select = $( "<select>" ).addClass( "form-control me-3 mb-2" ).on( "change", function() {
                    const selectedId = $( this ).val();
                    const attributeId = $( this ).data( "attribute-id" );
                    viewModel.loadProductItems( selectedId, attributeId );
                } );

                select.attr( "data-attribute-id", item.attributeId );

                if ( item.level > 0 ) {
                    select.css( "margin-left", ( 1.5 * item.level ) + "rem" );
                    select.css( "width", `calc(100% - ${1.5 * item.level}rem)` );
                }

                // const emptyOption = $( "<option>" ).val( "" ).html( "-- Seleziona valore attributo" );
                // select.append( emptyOption );

                values.forEach( function( attrValue ) {
                    const option = $( "<option>" )
                        .val( attrValue.productItemId )
                        .html( `<b>${attrName}</b> ${attrValue.attributeValue.rawValue.name}` );
                    select.append( option );
                } );

                // Imposto la option selezionata
                const selectedOption = values.find( attrValue => attrValue.selected === true );

                if ( selectedOption ) {
                    if ( selectedOption ) {
                        select.val( selectedOption.productItemId );
                    }
                } else {
                    select.prop( "selectedIndex", 0 ).trigger( "change" );
                }

                subContainer.append( select );
            } );
        },

        loadLines: function( onLoad ) {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/lines/22",
                callback: {
                    done: function( xhr ) {

                        viewModel.get( "lines" ).data( xhr.data );
                        NM.util.openModal( AP.plate.fields.modalRoot );

                        if ( onLoad !== undefined ) {
                            onLoad();
                        }
                    },
                },
            } );
        },

        loadModels: function( event ) {

            var lineId = viewModel.get( "detailForm.data.product.line.id" );

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/models/" + lineId,
                callback: {
                    done: function( xhr ) {
                        // console.log( "loadModels" );
                        viewModel.get( "models" ).data( xhr.data );
                        // viewModel.set( "detailForm.data.product.model.id", xhr.data[0] );

                    },
                },
            } );
        },

        loadFinishes: function( event ) {

            var lineId = viewModel.get( "detailForm.data.product.line.id" );

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/finishes/22/" + lineId,
                callback: {
                    done: function( xhr ) {

                        // console.log( "loadFinishes" );
                        viewModel.get( "finishes" ).data( xhr.data );

                    },
                },
            } );
        },

        resetForm: function() { },

        save: function() {

            const parsedData = viewModel.get( "detailForm.data" );
            var status = fields.modalRoot.find( ".save-status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            parsedData.quotationId = AP.page.quotation.id;
            parsedData.isClone = viewModel.get( "detailForm.isClone" );
            parsedData.type = "plate";

            var preview = $( "#plate-background" )[0];

            html2canvas( preview, { useCORS: true } ).then( function( canvas ) {
                const imgData = canvas.toDataURL( "image/png" ).replace( /^data:image\/png;base64,/, "" );
                parsedData.imageBase64 = imgData;
                parsedData.price = AP.quotation.pricing.getData().data;

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotation-items/plate",
                    data: JSON.stringify( parsedData ),
                    callback: {
                        done: function( xhr ) {
                            status.html( "" );
                            AP.widget.notify( "success", "Placca salvata correttamente." );
                            viewModel.set( "detailForm", defaultDetailForm );
                            setTimeout( () => window.location.reload(), 1000 );
                        }
                    }
                } );
            } );

            return false;
        },

        loadFruits: function() {

            var id = viewModel.get( "detailForm.data.id" );

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotation-items/plate/" + id + "/fruits",
                callback: {
                    done: function( xhr ) {

                        console.log( "loadFruits", xhr.data );

                        for ( var thisFruit of xhr.data ) {

                            var newFruit = createFruit( { position: 1, fruit: thisFruit.fruit } );

                            viewModel.set( "currentFruit", newFruit );
                            viewModel.get( "detailForm.data.fruits" ).add( newFruit );

                            pub.fruitsController.addFruitToPlate( mapFruitForPlate( newFruit ) );

                            viewModel.addProductItemsToFruit( newFruit.id );
                        }

                    },
                },
            } );


        },

        onSelectFruit: function( selectedFruit ) {

            var newFruit = createFruit( { position: 1, fruit: selectedFruit } );

            viewModel.set( "currentFruit", newFruit );
            viewModel.get( "detailForm.data.fruits" ).add( newFruit );

            console.log("pub.fruitsController", pub.fruitsController );

            pub.fruitsController.addFruitToPlate( mapFruitForPlate( newFruit ) );

            viewModel.addProductItemsToFruit( newFruit.id );

        },

    } );

    pub.new = function( onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.set( "detailForm.data.quotationZone", AP.quotation.detail.config().zone );

        viewModel.loadLines();

    };

    pub.edit = function( { id, onSave, clone = false } ) {

        viewModel.set( "detailForm", defaultDetailForm );

        viewModel.set( "detailForm.isClone", clone );

        if ( clone ) {
            viewModel.set( "detailForm.title", "Duplica placca" );
        }

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotation-items/plate/" + id,
            callback: {
                done: function( xhr ) {

                    viewModel.populateProduct( xhr.data.quotationItem.product ); // without items
                    viewModel.set( "detailForm.data.id", xhr.data.quotationItem.id );
                    viewModel.set( "detailForm.data.quotationZone", xhr.data.quotationItem.quotationZone );

                    // console.log( "productItems", "xhr.data.quotationItem.items" );

                    // var items = new kendo.data.DataSource();
                    // viewModel.set( "detailForm.data.items", items.data( xhr.data.items ) );

                    // console.log( "edit:get:items", viewModel.get( "detailForm.data.items" ) );

                    const delay = ( ms ) => new Promise( resolve => setTimeout( resolve, ms ) );

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

                },
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

        initFruitsSuggest();

        kendo.bind( settings.container, viewModel );
    };

    pub.getVM = function() {
        return viewModel;
    };

    return pub;
}() );
