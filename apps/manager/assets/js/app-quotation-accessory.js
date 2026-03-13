AP.namespace( "accessory" );

Object.assign( AP.accessory.fields, {
    modalRoot: $( "#accessory-modal" )
} );

$( document ).ready( function() {
    if ( AP.accessory.fields.modalRoot.length ) {
        AP.accessory.modal.init();
    }
} );

AP.accessory.modal = ( function() {

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
            special: false,
            quotationItem: {
                id: "",
                special: false,
                customImage: false,
                quantity: 1,
                price: {
                    id: null,
                },
                status: {
                    id: "ACT"
                },
                position: {
                    id: "",
                    code: ""
                },
                note: "",
                product: {
                    finish: {
                        id: ""
                    },
                    category: {
                        id: ""
                    },
                    line: {
                        id: ""
                    },
                    model: {
                        id: ""
                    },
                    items: new kendo.data.DataSource(),
                },
                quotationZone: {
                    id: ""
                }
            },
        },
        statuses: AP.page.statuses,
        itemStatuses: AP.page.itemStatuses,
        title: "Carica accessorio",
        canSave: false,
        productItemsNotes: [],
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,
        categories: new kendo.data.DataSource(),
        lines: new kendo.data.DataSource(),
        models: new kendo.data.DataSource(),
        finishes: new kendo.data.DataSource(),
        accessoryImages: new kendo.data.DataSource(),
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

        checkCanSave: function() {
            var vm = viewModel;
            if (
                vm.get( "detailForm.data.quotationItem.quantity" ) > 0 &&
                vm.get( "detailForm.data.quotationItem.product.finish.id" ) != "" &&
                vm.get( "detailForm.data.quotationItem.product.category.id" ) != "" &&
                vm.get( "detailForm.data.quotationItem.product.line.id" ) != "" &&
                vm.get( "detailForm.data.quotationItem.product.model.id" ) != ""
            ) {
                viewModel.set( "canSave", true );
            } else {
                viewModel.set( "canSave", false );
            }
        },

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
            viewModel.set( "detailForm.data.quotationItem.quotationZone", AP.quotation.detail.config().zone );
            $( "#accessoryProductCategory" ).prop( "disabled", false );
            $( "#accessoryLine" ).prop( "disabled", false );
            $( "#accessoryModel" ).prop( "disabled", false );
            $( "#accessory-product-items" ).empty();
        },

        loadLines: function( event ) {
            if (viewModel.get( "detailForm.data.quotationItem.product.category.id" ) && viewModel.get( "detailForm.data.quotationItem.product.category.id" ) != '') {
                NM.util.ajax( {
                    method: "GET",
                    url: "/manager/ajax/quotations/lines/" + viewModel.get( "detailForm.data.quotationItem.product.category.id" ),
                    callback: {
                        done: function( xhr ) {
                            xhr.data.unshift( { id: "", name: "-- Seleziona la linea" } );
                            viewModel.get( "lines" ).data( xhr.data );
                        },
                    },
                } );
            }
            this.checkCanSave();
            AP.setUserPref( "accessory.categoryId", viewModel.get( "detailForm.data.quotationItem.product.category.id" ) );
        },

        loadModels: function( event ) {
            if ( viewModel.get( "detailForm.data.quotationItem.product.line.id" ) != "" ) {
                NM.util.ajax( {
                    method: "GET",
                    url: "/manager/ajax/quotations/models/"
                        + viewModel.get( "detailForm.data.quotationItem.product.line.id" )
                        + "?catalogBundleCategoryId=" + viewModel.get( "detailForm.data.quotationItem.product.category.id" ),
                    callback: {
                        done: function( xhr ) {
                            xhr.data.unshift( { id: "", name: "-- Seleziona il Modello" } );
                            viewModel.get( "models" ).data( xhr.data );
                        },
                    },
                } );
            }
            this.checkCanSave();
            AP.setUserPref( "accessory.lineId", viewModel.get( "detailForm.data.quotationItem.product.line.id" ) );
        },

        loadFinishes: function( event ) {
            if ( viewModel.get( "detailForm.data.quotationItem.product.model.id" ) != "" ) {
                NM.util.ajax( {
                    method: "GET",
                    url: "/manager/ajax/quotations/finishes/" + viewModel.get( "detailForm.data.quotationItem.product.category.id" ) + "/" + viewModel.get( "detailForm.data.quotationItem.product.line.id" ),
                    callback: {
                        done: function( xhr ) {
                            xhr.data.unshift( { id: "", name: "-- Seleziona la Finitura" } );
                            viewModel.get( "finishes" ).data( xhr.data );
                            NM.util.ajax( {
                                method: "GET",
                                url: "/manager/ajax/model-config/get-by-params?categoryId=" +
                                    viewModel.get( "detailForm.data.quotationItem.product.category.id" ) +
                                    "&lineId=" +
                                    viewModel.get( "detailForm.data.quotationItem.product.line.id" ) +
                                    "&modelId=" +
                                    viewModel.get( "detailForm.data.quotationItem.product.model.id" ),
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
                                    }
                                }
                            } );
                        },
                    },
                } );
            }
            this.checkCanSave();
            AP.setUserPref( "accessory.modelId", viewModel.get( "detailForm.data.quotationItem.product.model.id" ) );
        },

        loadProduct: function() {
            $('#accessory-preview-background-tree').empty()
            const self = this;
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/products?categoryId=" +
                    viewModel.get( "detailForm.data.quotationItem.product.category.id" ) +
                    "&lineId=" + viewModel.get( "detailForm.data.quotationItem.product.line.id" ) +
                    "&modelId=" + viewModel.get( "detailForm.data.quotationItem.product.model.id" ) +
                    "&finishId=" + viewModel.get( "detailForm.data.quotationItem.product.finish.id" ),
                callback: {
                    done: async function( xhr ) {
                        if ( xhr.data ) {
                            viewModel.set( "detailForm.data.quotationItem.product.id", xhr.data[0].id );
                            viewModel.set( "detailForm.data.quotationItem.product.image", xhr.data[0].horizontalImage );
                            //al caricamento del prodotto, se la riga di preventivo prevede custom image, carico l'immagine manualmente leggendo da file per quotationItemId
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
                            } else {
                                if ( xhr.data[0].horizontalImage ) {
                                    viewModel.set( "backgroundImage", xhr.data[0].horizontalImage );
                                    viewModel.set( "backgroundImage.url", xhr.data[0].horizontalImage.uri );
                                } else {
                                    viewModel.set( "backgroundImage.url", "" );
                                }
                            }
                            if ( viewModel.get( "detailForm.data.quotationItem.product.finish.id" ) != "" ) {
                                await self.firstLoadProductItems();
                            }
                        }
                    },
                },
            } );
            this.checkCanSave();
            if ( viewModel.get( "detailForm.data.quotationItem.product.finish.id" ) != AP.getUserPref( "accessory.finishId" ) ) {
                AP.deleteUserPref( "accessory.product.items" );
            }
            AP.setUserPref( "accessory.finishId", viewModel.get( "detailForm.data.quotationItem.product.finish.id" ) );
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
							// TODO Valutare di rimuovere questo if, 99% non serve a niente
                            if ( quotationItemId != "" || !AP.getUserPref( "accessory.product.items" ) || AP.getUserPref( "accessory.product.items" ).length == 0 ) {
                                viewModel.set( "detailForm.data.quotationItem.product.items", new kendo.data.DataSource() );
                            } else {
                                if ( quotationItemId == "" ) {
                                    const itemsDataSource = new kendo.data.DataSource( {
                                        data: AP.getUserPref( "accessory.product.items" )
                                    } );
                                    viewModel.set( "detailForm.data.quotationItem.product.items", itemsDataSource );
                                    viewModel.get( "detailForm.data.quotationItem.product.items" ).read();
                                    viewModel.renderProductPreview( viewModel.get( "detailForm.data.quotationItem.product.items" ) );
                                }
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
                                            level: 0,
                                            selected: false,
                                            horizontalImage: item.horizontalImage,
                                            verticalImage: item.verticalImage
                                        } );
                                        productItems.trigger( "change" );
                                    }
                                } else {
                                    const parsedData = {
                                        attribute_id: item.attribute.id,
                                        attribute_name: item.attribute.name,
                                        parent_attribute_id: null,
                                        level: 0,
                                        values: [
                                            {
                                                attributeValue: item.attributeValue,
                                                product_item_id: item.id,
                                                selected: false,
                                                horizontalImage: item.horizontalImage,
                                                verticalImage: item.verticalImage
                                            }
                                        ]
                                    };
                                    productItems.add( parsedData );
                                }
                            } );

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
                                const toInsert = false;
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
                                        selected: false,
                                        horizontalImage: item.horizontalImage,
                                        verticalImage: item.verticalImage
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
                            if ( productItems && productItems.data().length > 0 ) {
                                viewModel.renderProductPreview( productItems );
                            }
                            resolve();
							selectedProductItemIds = []
							for (const pi of productItems.data()) {
								selectedValue = pi.values.filter( v => v.selected )
								if ( selectedValue.length > 0 ) {
									selectedProductItemIds.push( selectedValue[0].product_item_id );
								}
							}

							if (selectedProductItemIds.length) {
								NM.util.ajax({
										method: "POST",
										url: '/manager/ajax/combinations/findByListOfProductItemIds',
										data: JSON.stringify({productItemIds: selectedProductItemIds}),
										callback: {
											done: function (xhr) {
												if (xhr.status === 'SUCCESS' && xhr.data?.horizontalImage) {
                                                $( "#accessory-preview-background-tree" ).empty();
                                                    $( "#accessory-preview-background-tree" ).append( `<img src="${xhr.data.horizontalImage}" style="width: 500px; height: auto;">` );
                                                }
											}
										}
									}
								)
							}
                        },
                        fail: function( err ) {
                            reject( err );
                        }
                    }
                } );
            } );
        },

        renderProductPreview: function( productItems ) {
            // $( "#accessory-preview-background-tree" ).empty();
            let selectedValues = []
            for (const productItem of productItems._data) {
                const productItemSelectedData = productItem.values.filter( ( value ) => { return value.selected == true; } );
                selectedValues = selectedValues.concat( productItemSelectedData );
            }
            $( "#accessory-preview-background-tree" ).empty();

            if ( selectedValues.length > 0 ) {
                for (const selectedValue of selectedValues) {
                    if ( selectedValue.horizontalImage ) {
                        $( "#accessory-preview-background-tree" ).append( `<img src="${selectedValue.horizontalImage.uri}" style="width: 500px; height: auto;position: absolute; top: 0; left: 0;">` );
                    } else if ( selectedValue.attributeValue?.horizontalImage ) {
                        $( "#accessory-preview-background-tree" ).append( `<img src="${selectedValue.attributeValue.horizontalImage.uri}" style="width: 500px; height: auto;position: absolute; top: 0; left: 0;">` );
                    }
                }
            }
            return true;
        },

        renderProductItems: function() {
            const container = $( "#accessory-product-items" );
            container.empty();
            const productItems = viewModel.get( "detailForm.data.quotationItem.product.items" );
            const attributeArray = productItems.data();
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
                    })
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

        visibleUpperClearButton: function() {
            const id = this.get( "detailForm.data.id" );
            return id == "";
        },

        visibleLowerClearButton: function() {
            const finishId = this.get( "detailForm.data.quotationItem.product.finish.id" );
            const id = this.get( "detailForm.data.id" );
            return finishId == "" && id == "";
        },

        clearFilters: function() {
            viewModel.resetForm();
            AP.deleteUserPref( "accessory.categoryId" );
            AP.deleteUserPref( "accessory.lineId" );
            AP.deleteUserPref( "accessory.modelId" );
            AP.deleteUserPref( "accessory.finishId" );
            AP.deleteUserPref( "accessory.product.items" );
            this.checkCanSave();
        },

        save: function( event ) {
            AP.loading.show();

            var quotationId = AP.page.quotation.id;
            
            //quando salvo, se sono in modalità custom image, devo scegliere il canvas dell'immagine custom da passare a 
            let preview = $( "#accessory-preview-background" )[0];
            if (viewModel.get('detailForm.data.quotationItem') && viewModel.get('detailForm.data.quotationItem.id') && viewModel.get('detailForm.data.quotationItem.customImage') && viewModel.get('detailForm.data.quotationItem.customImage') == true) {
                //se non ho un immagine selezionata, ma sono in modalità custom image, vengo bloccato
               if (!viewModel.get('backgroundCustomImage.url')) {
                    AP.widget.notify( "error", "Hai scelto custom image, devi selezionare un'immagine prima di salvare." );
                    AP.loading.hide()
                    return false;
               }

               preview = $( "#accessory-preview-custom-background" )[0];
            }

            const parsedData = viewModel.get( "detailForm.data" );
            parsedData.quotationId = quotationId;
            parsedData.type = "accessory";
            parsedData.quotationItem.quotationZone = (viewModel.get('quotationSubzone.id') && viewModel.get('quotationSubzone.id') != '') ? viewModel.get('quotationSubzone') : viewModel.get('quotationZone')

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
                if (viewModel.get('cloneMode')) {
                    parsedData.quotationItem.id = ""
                }

                JSON.stringify( parsedData );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotation-items/accessory",
                    data: JSON.stringify( parsedData ),
                    callback: {
                        done: function( xhr ) {
                            if( xhr.status === "ERROR" ) {
                                if ( xhr.data && xhr.data.error ) {
                                    AP.widget.notify( "error", xhr.data.error );
                                } else {
                                    AP.widget.notify( "error", "Errore nel salvataggio della segnaletica." );
                                }
                                AP.loading.hide();
                            }

                            if ( xhr.status === "SUCCESS" ) {
                                $( "#accessory-modal" ).hide();
                                AP.widget.notify( "success", "Segnaletica salvata nel preventivo." );
                                viewModel.set( "detailForm", defaultDetailForm );
                                setTimeout( function() {
                                    AP.loading.hide();
                                    window.location.reload();
                                }
                                , 1000 );
                            }
                        }
                    }
                } );
            } );

            return false;
        },

        handleSelectChanges: function() {
            $( "#accessoryProductCategory" ).on( "change", function(e) {
                viewModel.set('detailForm.data.quotationItem.product.line', { 'id':'' })
                viewModel.set('detailForm.data.quotationItem.product.model', { 'id':'' })
                viewModel.set('detailForm.data.quotationItem.product.finish', { 'id':'' })
                viewModel.set('detailForm.data.quotationItem.product.items', [])
                AP.deleteUserPref( "accessory.lineId" );
                AP.deleteUserPref( "accessory.modelId" );
                AP.deleteUserPref( "accessory.finishId" );
            } );
            $( "#accessoryLine" ).on( "change", function(e) {
                viewModel.set('detailForm.data.quotationItem.product.model', { 'id':'' })
                viewModel.set('detailForm.data.quotationItem.product.finish', { 'id':'' })
                viewModel.set('detailForm.data.quotationItem.product.items', [])
                AP.deleteUserPref( "accessory.modelId" );
                AP.deleteUserPref( "accessory.finishId" );
            } );
            $( "#accessoryModel" ).on( "change", function(e) {
                viewModel.set('detailForm.data.quotationItem.product.finish', { 'id':'' })
                viewModel.set('detailForm.data.quotationItem.product.items', [])
                AP.deleteUserPref( "accessory.finishId" );
            } );
        }
    } );

    pub.new = async function( onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }
        viewModel.set( "detailForm.data.quotationZone", AP.quotation.detail.config().zone );
        pricingApp().init( "accessory", undefined );

        let categoriesResponse = await NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/categories?typeId=ACC",
            callback: {
                done: function( xhr ) {
					//NOOP
                },
            },
        } );

		if ( categoriesResponse.data.length > 0 ) {
            categoriesResponse.data = categoriesResponse.data.filter(c => c.type.id == 'ACC')
			categoriesResponse.data.unshift( { id: "", name: "-- Seleziona la Categoria" } );
			viewModel.get( "categories" ).data( categoriesResponse.data );
		}
		NM.util.openModal( AP.accessory.fields.modalRoot );


        viewModel.resetForm();
        viewModel.set( "detailForm.data.quotationItem.quotationZone", AP.quotation.detail.config().zone );

        viewModel.handleSelectChanges()

        const accessoryCategoryId = AP.getUserPref( "accessory.categoryId" )
        const accessoryLineId = AP.getUserPref( "accessory.lineId" )
        const accessoryModelId = AP.getUserPref( "accessory.modelId" )
        const accessoryFinishId = AP.getUserPref( "accessory.finishId" )

        if ( accessoryCategoryId ) {
            viewModel.set( "detailForm.data.quotationItem.product.category.id", accessoryCategoryId );
            await viewModel.loadLines();
        }

        if ( accessoryLineId ) {
            viewModel.set( "detailForm.data.quotationItem.product.line.id", accessoryLineId );
            await viewModel.loadModels();
        }

        if ( accessoryModelId ) {
            viewModel.set( "detailForm.data.quotationItem.product.model.id", accessoryModelId );
            await viewModel.loadFinishes();
        }

        if ( accessoryFinishId ) {
            viewModel.set( "detailForm.data.quotationItem.product.finish.id", accessoryFinishId );
            await viewModel.loadProduct();
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

    pub.getItem = function() {
        return viewModel.get( "detailForm.data" );
    };

    pub.edit = async function( { id, clone = false, onSave } ) {
        viewModel.resetForm();

        const categoriesResponse = await NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/categories?typeId=ACC",
            callback: {
                done: function( xhr ) {
                    //NOOP
                },
            },
        } );

		categoriesResponse.data.unshift( { id: "", name: "" } );
		viewModel.get( "categories" ).data( categoriesResponse.data );
		NM.util.openModal( AP.accessory.fields.modalRoot );

		const accessoryResponse = await NM.util.ajax( {
			method: "GET",
			url: "/manager/ajax/quotation-items/accessory/" + id,
			callback: {
				done: function( xhr ) {
					//NOOP
				},
			},
		} );

		if ( accessoryResponse.status === "SUCCESS" ) {
			var data = accessoryResponse.data;

			viewModel.set( "detailForm.data", data );
			viewModel.set( "detailForm.title", "Modifica accessorio" );

            viewModel.set( "detailForm.data.quotationItem.position", data.quotationItem.position ?? { 'id': '', 'code': '' })

			await viewModel.loadLines();

			await viewModel.loadModels();
			await viewModel.loadFinishes();
			await viewModel.loadProduct();
			initPositionSuggest();
		}

		pricingApp().init( "accessory", { data: accessoryResponse.data.quotationItem.price } );

		renderQuotationItemTotals( id );

        $( "#accessoryProductCategory" ).prop( "disabled", true );
        $( "#accessoryLine" ).prop( "disabled", true );
        $( "#accessoryModel" ).prop( "disabled", true );
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
            viewModel.set('detailForm.title', "Clona Accessorio")
            $('#save-accessory-button').css("display", "none")
            $('#clone-accessory-button').css("display", "block")
        } else {
            viewModel.set('cloneMode', false)
            $('#save-accessory-button').css("display", "block")
            $('#clone-accessory-button').css("display", "none")
        }
        
        //aggiunto queste due righe per gestire i boolean
        viewModel.set('detailForm.data.quotationItem.customImage', data.quotationItem.customImage == 'true')
        viewModel.set('detailForm.data.quotationItem.special', data.quotationItem.special == 'true')

        //in base al bool di customImage setto questi due parametri, se showCustomImage mostrerò il div con l'immagine custom e nasconderò quello con l'immagine composta dai vari attributes
        //altrimenti farò il contrario
        viewModel.set('showCustomImage', viewModel.get('detailForm.data.quotationItem.customImage'))
        viewModel.set('showImage', !viewModel.get('detailForm.data.quotationItem.customImage'))

        AP.loading.hide();
    };

    pub.init = function() {
        const url = new URL(window.location);

        //tolto il parametro reset dall'url quando apro la pagina. fatto perchè quando salvo l'immagine custom sono costretto a metterlo per far si che si vedo nella pagina del preventivo.
        //aggiungo questa istruzione per evitare che rimanga nell'url e rallenti la pagina nelle successive operazioni.
        if (url.searchParams.has("reset")) {
            url.searchParams.delete("reset");
            window.history.replaceState({}, "", url);
        }
        kendo.bind( AP.accessory.fields.modalRoot, viewModel );
    };

    pub.getData = function() {
        return viewModel.get( "detailForm.data" );
    };

    var initPositionSuggest = function() {
        var suggest = $( "#accessory-quotation-item-pricing-box-position" );
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
                    viewModel.set( "detailForm.data.quotationItem.position", position );
                }
            },

            select: function( event ) {
                var position = this.dataItem( event.item.index() );
                viewModel.set( "detailForm.data.quotationItem.position", position );
                var sel = viewModel.get( "detailForm.data.quotationItem.position" );
            }
        } );

    };

    renderQuotationItemTotals = function( quotationItemId ) {
        NM.util.ajax( {
            method: "GET",
            url: `/manager/ajax/quotation-items/${quotationItemId}/total`,
            callback: {
                done: function( xhr ) {
                    if( xhr.data ) {
                        if ( !xhr.data.id || xhr.data.id != quotationItemId ) {
                            $( "#quotation-totals-item" ).hide();
                        } else {
                            viewModel.set( "detailForm.data.totals", xhr.data );
                            var totals = viewModel.get( "detailForm.data.totals" );
                            if ( xhr.data ) {
                                const table = $( "#quotation-totals-item" ).find( "table" )[0];
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
                            $( "#quotation-totals-item" ).show();
                        }
                    }
                }
            }
        } );
    };

    return pub;
} () );
