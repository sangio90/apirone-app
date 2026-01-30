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
    var pub = {};
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
                    items: new kendo.data.DataSource(),
                },
                quotationZone: {
                    id: ""
                }
            },
            status: {
                id: "ACT",
            }
        },
        statuses: AP.page.statuses,
        title: "Carica accessorio",
        canSave: false,
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

        checkCanSave: function() {
            var vm = viewModel;
            if (
                vm.get( "detailForm.data.quotationItem.quantity" ) > 0 &&
                vm.get( "detailForm.data.quotationItem.product.finish.id" ) != "" &&
                vm.get( "detailForm.data.quotationItem.product.catalogBundle.category.id" ) != "" &&
                vm.get( "detailForm.data.quotationItem.product.catalogBundle.line.id" ) != "" &&
                vm.get( "detailForm.data.quotationItem.product.catalogBundle.model.id" ) != ""
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
            $( "#accessoryRow" ).prop( "disabled", false );
            $( "#accessoryModel" ).prop( "disabled", false );
            $( "#accessoryFinish" ).prop( "disabled", false );
            $( "#accessory-product-items" ).empty();
        },

        loadLines: function( event ) {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/lines/" + viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.category.id" ),
                callback: {
                    done: function( xhr ) {
                        xhr.data.unshift( { id: "", name: "-- Seleziona la Linea" } );
                        viewModel.get( "lines" ).data( xhr.data );
                    },
                },
            } );
            this.checkCanSave();
            AP.setUserPref( "accessory.categoryId", viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.category.id" ) );
        },

        loadModels: function( event ) {
            if ( viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.line.id" ) != "" ) {
                $( "#accessoryProductCategory" ).prop( "disabled", true );
                $( "#accessory-preview-background" ).css( {
                    width: "500px",
                    height: "500px"
                } );
            } else {
                $( "#accessoryProductCategory" ).prop( "disabled", false );
            }
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/models/" + viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.line.id" ),
                callback: {
                    done: function( xhr ) {
                        xhr.data.unshift( { id: "", name: "-- Seleziona il Modello" } );
                        viewModel.get( "models" ).data( xhr.data );
                    },
                },
            } );
            this.checkCanSave();
            AP.setUserPref( "accessory.lineId", viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.line.id" ) );
        },

        loadFinishes: function( event ) {
            if ( viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.model.id" ) != "" ) {
                $( "#accessoryRow" ).prop( "disabled", true );
                NM.util.ajax( {
                    method: "GET",
                    url: "/manager/ajax/quotations/finishes/" + viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.category.id" ) + "/" + viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.line.id" ),
                    callback: {
                        done: function( xhr ) {
                            xhr.data.unshift( { id: "", name: "-- Seleziona la Finitura" } );
                            viewModel.get( "finishes" ).data( xhr.data );
                            NM.util.ajax( {
                                method: "GET",
                                url: "/manager/ajax/model-config/get-by-params?categoryId=" +
                                    viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.category.id" ) +
                                    "&lineId=" +
                                    viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.line.id" ) +
                                    "&modelId=" +
                                    viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.model.id" ),
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

                                        $( "#accessory-preview-container" ).css( {
                                            width: "500px",
                                            height: "500px"
                                        } );
                                    }
                                }
                            } );
                        },
                    },
                } );
            } else {
                $( "#accessoryRow" ).prop( "disabled", false );

            }
            this.checkCanSave();
            AP.setUserPref( "accessory.modelId", viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.model.id" ) );
        },

        loadProduct: function() {
            $( "#accessory-preview-background" ).empty();
            if ( viewModel.get( "detailForm.data.quotationItem.product.finish.id" ) != "" ) {
                $( "#accessoryModel" ).prop( "disabled", true );
            } else {
                $( "#accessoryModel" ).prop( "disabled", false );
            }
            const self = this;
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/products?categoryId=" +
                    viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.category.id" ) +
                    "&lineId=" + viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.line.id" ) +
                    "&modelId=" + viewModel.get( "detailForm.data.quotationItem.product.catalogBundle.model.id" ) +
                    "&finishId=" + viewModel.get( "detailForm.data.quotationItem.product.finish.id" ),
                callback: {
                    done: async function( xhr ) {
                        if ( xhr.data ) {
                            viewModel.set( "detailForm.data.quotationItem.product.id", xhr.data[0].id );
                            viewModel.set( "detailForm.data.quotationItem.product.image", xhr.data[0].horizontalImage );
                            if ( xhr.data[0].horizontalImage ) {
                                viewModel.set( "backgroundImage", xhr.data[0].horizontalImage );
                                viewModel.set( "backgroundImage.url", "url('" + xhr.data[0].horizontalImage.uri + "')" );
                            } else {
                                viewModel.set( "backgroundImage.url", "url()" );
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
                            if ( !viewModel.get( "detailForm.data.quotationItem.product.image" ) && xhr.data[0].horizontalImage ) {
                                viewModel.set( "detailForm.data.quotationItem.product.image", xhr.data[0].horizontalImage );
                                viewModel.set( "backgroundImage", xhr.data[0].horizontalImage );
                                viewModel.set( "backgroundImage.url", "url('" + xhr.data[0].horizontalImage.uri + "')" );
                            }
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
                                            selected: false
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
                                                selected: false
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
                    AP.setUserPref( "accessory.product.items", productItems.data() );
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
                                } );
                                if ( parentIndex !== -1 ) {
                                    const parent = productItems.at( parentIndex );
                                    parent.get( "values" ).forEach( v => {
                                        v.selected = v.product_item_id == originId;
                                    } );
                                }
                            }

                            viewModel.renderProductItems();
                            if ( productItems && productItems.data().length > 0 ) {
                                viewModel.renderProductPreview( productItems );
                            }
                            AP.setUserPref( "accessory.product.items", productItems.data() );
                            resolve();
                        },
                        fail: function( err ) {
                            reject( err );
                        }
                    }
                } );
            } );
        },

        renderProductPreview: function( productItems ) {
            productItems.data().forEach( function( item ) {
                const selectedValues = item.values.filter( ( value ) => { return value.selected == true; } );
                if ( selectedValues.length > 0 ) {
                    if ( selectedValues[0].attributeValue?.horizontalImage ) {
                        // Probabilmente è giusto l'append, ma al momento vengono affiancati e non sovrapposti
                        // $( "#accessory-preview-background" ).append( `<img src="${selectedValues[0].attributeValue.image.uri}" style="postion: absolute; top: 0; left: 0;">` );
                        $( "#accessory-preview-background" ).html( `<img src="${selectedValues[0].attributeValue.horizontalImage.uri}" style="postion: absolute; top: 0; left: 0;">` );
                    }
                }
            } );
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
            const parsedData = viewModel.get( "detailForm.data" );
            parsedData.quotationId = quotationId;
            parsedData.type = "accessory";
            var preview = $( "#accessory-preview-background" )[0];

            html2canvas( preview, { useCORS: true } ).then( function( canvas ) {
                const imgData = canvas.toDataURL( "image/png" ).replace( /^data:image\/png;base64,/, "" );
                parsedData.imageBase64 = imgData;
                parsedData.price = AP.quotation.pricing.getData().data;

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotation-items/accessory",
                    data: JSON.stringify( parsedData ),
                    callback: {
                        done: function( xhr ) {
                            if( xhr.status == "ERRORE" ) {
                                if ( xhr.data && xhr.data.error ) {
                                    AP.widget.notify( "error", xhr.data.error );
                                } else {
                                    AP.widget.notify( "error", "Errore nel salvataggio della segnaletica." );
                                }
                                AP.loading.hide();
                            }
                            if ( xhr.status == "SUCCESS" ) {
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
    } );

    pub.new = function( onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/categories?typeId=ACC",
            callback: {
                done: function( xhr ) {
                    if ( xhr.data.length > 0 ) {
                        xhr.data.unshift( { id: "", name: "-- Seleziona la Categoria" } );
                        viewModel.get( "categories" ).data( xhr.data );
                    }
                    NM.util.openModal( AP.accessory.fields.modalRoot );
                },
            },
        } );
        viewModel.resetForm();
        viewModel.set( "detailForm.data.quotationItem.quotationZone", AP.quotation.detail.config().zone );


        if ( AP.getUserPref( "accessory.categoryId" ) ) {
            viewModel.set( "detailForm.data.quotationItem.product.catalogBundle.category.id", AP.getUserPref( "accessory.categoryId" ) );
        }

        if ( AP.getUserPref( "accessory.lineId" ) ) {
            viewModel.set( "detailForm.data.quotationItem.product.catalogBundle.line.id", AP.getUserPref( "accessory.lineId" ) );
        }

        if ( AP.getUserPref( "accessory.modelId" ) ) {
            viewModel.set( "detailForm.data.quotationItem.product.catalogBundle.model.id", AP.getUserPref( "accessory.modelId" ) );
        }

        if ( AP.getUserPref( "accessory.finishId" ) ) {
            viewModel.set( "detailForm.data.quotationItem.product.finish.id", AP.getUserPref( "accessory.finishId" ) );
        }

        if ( AP.getUserPref( "accessory.categoryId" ) ) {
            viewModel.loadLines();
            setTimeout( function() {
                if ( AP.getUserPref( "accessory.lineId" ) ) {
                    viewModel.loadModels();
                    setTimeout( function() {
                        if ( AP.getUserPref( "accessory.modelId" ) ) {
                            viewModel.loadFinishes();
                            setTimeout( function() {
                                if ( AP.getUserPref( "accessory.finishId" ) ) {
                                    viewModel.loadProduct();
                                    setTimeout( function() {

                                    }, 200 );
                                }
                            }, 200 );
                        }
                    }, 200 );
                }
            }, 200 );
        }
    };

    pub.edit = function( { id, onSave } ) {
        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/categories?typeId=ACC",
            callback: {
                done: function( xhr ) {
                    xhr.data.unshift( { id: "", name: "" } );
                    viewModel.get( "categories" ).data( xhr.data );
                    NM.util.openModal( AP.accessory.fields.modalRoot );
                },
            },
        } );

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotation-items/accessory/" + id,
            callback: {
                done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {
                        var data = xhr.data;
                        viewModel.set( "detailForm.data", data );
                        viewModel.set( "detailForm.title", "Modifica accessorio" );

                        viewModel.loadLines();

                        setTimeout( function() {
                            viewModel.loadModels();
                            setTimeout( function() {
                                viewModel.loadFinishes();
                                setTimeout( function() {
                                    viewModel.loadProduct();
                                }, 100 );
                            }, 100 );
                        }, 100 );
                    }
                },
            },
        } );

        renderQuotationItemTotals( id );
    };

    pub.init = function() {
        kendo.bind( AP.accessory.fields.modalRoot, viewModel );
    };

    pub.getData = function() {
        return viewModel.get( "detailForm.data" );
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
