AP.product = AP.product || {};

AP.product.fields = {
    rootDetail: $( "#product-detail-root" ),
    configRow: $( "#product-config-row" ),
    attributeSearchForm: $( "#attributes-search-form" ),
    attributeModal: $( "#product-attributes-list-modal" ),
    imagesModal: $( "#product-images-list-modal" ),
    reorderingModal: $( "#product-sorting-modal" ),
};

$( document ).ready( function() {
    if ( AP.product.fields.rootDetail.length ) {
        AP.product.items.init();
    }
} );

AP.product.items = ( function() {
    var pub = {};

    var fields = AP.product.fields;
    var componentApp = AP.component.list;
    var attributeApp = AP.attribute.detail;

    var dataSources = {
        items: NM.kendo.dataSource(
            {
                url: "/manager/ajax/products/" + AP.page.productId + "/items",
                serverFiltering: false,
                serverPaging: false,
            }
        ),
        orderingItems: NM.kendo.dataSource( { url: "/manager/ajax/products/" + AP.page.productId + "/items/order" } ),
        orderingAttributes: NM.kendo.dataSource( { url: "/manager/ajax/products/" + AP.page.productId + "/attributes/order" } ),
        attributesList: undefined,
    };

    var normalizeComponentItem = function( data ) {
        var item = {
            id: 0,
            attribute: {
                id: 0,
                name: "",
            },
            attributeValue: {
                id: 0,
                name: "",
            },
        };

        if ( data?.attributeValue ) {
            item = {
                id: data.id,
                attribute: {
                    id: data.attribute.id,
                    name: data.attribute.name,
                },
                attributeValue: {
                    id: data.attributeValue.id,
                    name: data.attributeValue.name,
                },
            };
        }

        return item;
    };

    var refreshUnlinkedCount = function() {

        var data = viewModel.get( "items" ).data();

        var unlinked = 0;

        for ( var item of data ) {
            if ( item.id < 0 ) {
                unlinked++;
            }
        }

        viewModel.set( "unlinkedCount", unlinked );

    };

    var fireFilter = function() {

        var filterState = AP.getUserPref( "product.items.showUnlinked", false );

        if ( !filterState ) {
            viewModel.get( "items" ).filter( { field: "id", operator: "gt", value: 0 } );
        } else {
            viewModel.get( "items" ).filter( {} );
        }

        AP.setUserPref( "product.items.showUnlinked", !filterState );

    };

    var viewModel = kendo.observable( {
        textToggleLink: function() {

            var text = "";

            // var filterState = AP.getUserPref( "product.items.showUnlinked" );

            var count = viewModel.get( "unlinkedCount" );

            /*
            TODO: non riesco ad aggiornare "text", mentre "count" viene aggiornato
            if ( !filterState ) {
                console.log( "nascondi" );
                var text = "Nascondi " + count + " attributi non collegati";
            } else {
                console.log( "mostra" );
                var text = "Mostra " + count + " attributi non collegati";
            }
            */

            var text = "Mostra/nascondi " + count + " attributi non collegati";

            return text;
        },
        items: dataSources.items, // i need to run after user pref
        orderingItems: dataSources.orderingItems,
        attributesList: dataSources.attributesList,
        orderingAttributes: dataSources.orderingAttributes,
        itemForAttributes: undefined,
        images: undefined,
        currentImageEntity: undefined,
        currentUploadUrl: undefined,
        unlinkedCount: 0,

        /*
			attributes methods
		*/

        toggleUnlinked: function( event ) {

            fireFilter();
            viewModel.textToggleLink();

            return false;

        },

        getImageTypeText: function( event ) {
            var text = AP.util.getTextItem( event.type.texts.toJSON() );

            return text.name + " " + event.shortId;
        },

        getImageSrc: function( event ) {
            var uri = event.uri;

            if ( event.uri != "" ) {
                var replaced = uri.replace( "_ori", "500" );

                return replaced;
            }

            return "/assets/main/img/img-not-found.png";
        },

        deleteImage: function( event ) {
            NM.util.ajax( {
                method: "DELETE",
                url: "/manager/ajax/products/" + event.data.id + "/images",
                callback: {
                    done: function( xhr ) {
                        // refreshDatasources();

                        setTimeout( () => $( "#product-images-list-modal" ).modal( "hide" ), 600 );

                    },
                },
            } );
        },

        getImageHref: function( event ) {
            var uri = event.uri;

            if ( event.uri != "" ) {
                var replaced = uri.replace( "_ori", "500" );

                return replaced;
            }

            return "/assets/main/img/img-not-found.png";
        },

        selectAttribute: function( event ) {
            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/products/" + AP.page.productId + "/items",
                data: {
                    attributeId: event.data.id,
                    originId: viewModel.get( "itemForAttributes.id" ),
                },
                callback: {
                    done: function( xhr ) {
                        refreshDatasources();
                        setTimeout( () => fields.attributeModal.modal( "hide" ), 600 );
                    },
                },
            } );
        },

        getAttributeName: function( event ) {
            var text = AP.util.getTextItem( event.texts );

            return text.name;
        },

        addAttribute: function( event ) {
            attributeApp.new( {
                callback: {
                    onCreate: function() {
                        viewModel.attributesList.read();
                    },
                },
            } );

            return false;
        },

        removeAttributes: function( event ) {
            var checks = $( "#product-items-grid" ).find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/products/" + AP.page.productId + "/items",
                    data: { items: ids },
                    callback: {
                        done: function( xhr ) {
                            AP.widget.notify( "success", xhr.data.message.text );

                            // viewModel.items.read();
                            refreshDatasources();
                        },
                    },
                } );
            } else {
                AP.widget.notify( "warning", "Seleziona almeno un attributo" );
            }
        },

        openAttributesList: function( event ) {
            var item = normalizeComponentItem( event.data );

            viewModel.set( "itemForAttributes", item );

            NM.util.openModal( fields.attributeModal );

            this.searchAttributes();

            return false;
        },

        addValue: function( event ) {

            console.log( "event:addValue", event );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/products/" + AP.page.productId + "/values",
                data: JSON.stringify( event.data ),
                callback: {
                    done: function( xhr ) {
                        viewModel.get( "items" ).read();
                        AP.widget.notify( "success", xhr.data.message.text );
                    },
                },
            } );

            return false;
        },

        openReorderingModal: function( event ) {
            NM.util.openModal( fields.reorderingModal );

            return false;
        },

        openImagesList: function( event ) {
            var element = $( event.currentTarget );

            if ( !element.attr( "data-type" ) ) {
                console.error( "ERROR. Set data-type attribute in currentTarget" );
                return;
            }

            var type = element.data( "type" );

            switch ( type ) {
            case "productItem":
                var value = {
                    type: "item",
                    id: event.data.id,
                };

                var thisUrl = "/manager/ajax/product-items/" + event.data.id + "/images";

                break;

            case "product":
                var value = {
                    type: "product",
                    id: AP.page.productId,
                };

                var thisUrl = "/manager/ajax/products/" + AP.page.productId + "/images";

                break;

            default:
                console.error( "ERROR. Type [" + type + "] for image not found" );
            }

            var dataSource = NM.kendo.dataSource( { url: thisUrl } );

            viewModel.set( "currentImageEntity", value );
            viewModel.set( "currentUploadUrl", thisUrl );
            viewModel.set( "images", dataSource );

            initUpload();

            return false;
        },

        openAttributeValues: function( event ) {

            attributeApp.edit( {
                id: event.data.id,
                callback: {
                    onSave: function() {
                        viewModel.searchAttributes();
                    },
                },
            } );

            return false;
        },

        searchAttributes: function( event ) {
            var thisForm = fields.attributeSearchForm;
            var params = thisForm.serialize();

            var dataSource = NM.kendo.dataSource( {
                url: "/manager/ajax/attributes?" + params,
            } );

            viewModel.set( "attributesList", dataSource );

            return false;
        },

        /*
			// attributes methods
		*/

        openComponentsList: function( event ) {

            var element = $( event.currentTarget );

            if ( !element.attr( "data-type" ) ) {
                console.error( "ERROR. Set data-type attribute in currentTarget" );
                return;
            }

            var type = element.data( "type" );

            switch ( type ) {
            case "catalogBundle":
                var value = {
                    type: "catalogBundle",
                    model: {
                        id: element.data( "model-id" ),
                        name: element.data( "model-name" ),
                    },
                    line: {
                        id: element.data( "line-id" ),
                        name: element.data( "line-name" ),
                    },
                };

                break;

            case "item":
                var value = {
                    type: "item",
                    item: {
                        id: event.data.id,
                    },
                    attribute: {
                        id: event.data.attribute.id,
                        name: event.data.attribute.name,
                    },
                    attributeValue: {
                        id: event.data.attributeValue.id,
                        // name: event.data.attributeValue.name,
                        rawValue: {
                            id: event.data.attributeValue.rawValue.id,
                            name: event.data.attributeValue.rawValue.name,
                        },
                    },
                };

                break;

            case "product":
                var value = {
                    type: "product",
                    product: {
                        id: element.data( "product-id" ),
                        name: element.data( "product-name" ),
                    },
                };

                break;

            default:
            }

            componentApp.open( value );

            return false;
        },

        showItems: function() {
            return viewModel.get( "items" ).view().length ? true : false;
        },

        showImagesList: function() {
            NM.util.openModal( $( "#product-images-list-modal" ) );
        },

        changeUri: function( event ) {

            var thisButton = $( event.currentTarget );

            var thisForm = AP.product.fields.configRow;
            var found = false;

            var finishEle = thisForm.find( "[name=finishId]" );
            var modelEle = thisForm.find( "[name=modelId]" );

            finishEle.css( "border", "1px solid #ced4da" );
            modelEle.css( "border", "1px solid #ced4da" );

            var lineId = AP.page.lineId;
            var modelId = modelEle.val();
            var finishId = finishEle.val();

            var products = AP.page.products;
            var productId = AP.page.productId;

            products?.forEach( function( product ) {

                if ( lineId == product.line.id && finishId == product.finish.id && modelId == product.model.id ) {
                    found = true;
                    window.location.href = "/manager/products/" + product.id;
                }
            } );

            if ( !found ) {
                thisButton.val( "" );
                thisButton.attr( "style", "border: 1px solid Red !Important" );
            }

        },

        // TODO: not used, to remove
        loadModels: function() {
            var thisForm = AP.product.fields.configRow;

            var finishEle = thisForm.find( "[name=finishId]" );
            var modelEle = thisForm.find( "[name=modelId]" );

            var lineId = AP.page.lineId;
            // var modelId = modelEle.val();
            var finishId = finishEle.val();

            var products = AP.page.products;
            var productId = AP.page.productId;

            modelEle.empty( "" );

            modelEle.append(
                $( "<option>", {
                    value: "",
                    text: "-- seleziona",
                } ),
            );

            modelEle.val( "" );

            var found = false;
            var opts = [];

            products?.forEach( function( product ) {
                if ( lineId == product.line.id && finishId == product.finish.id ) {

                    if ( product.id == productId ) {
                        found = true;
                    }

                    opts.push( { productId: product.id, modelCode: product.model.code, finishId: product.finish.id } );

                    modelEle.append( opt );
                }
            } );

            // sort by alpha
            opts.sort( ( a, b ) => a.modelCode.localeCompare( b.modelCode, "it-IT" ) );

            for ( var thisOpt of opts ) {
                var opt = $( "<option>", {
                    value: thisOpt.combinatioId,
                    text: thisOpt.modelCode,
                } );

                modelEle.append( opt );
            }

            found ? modelEle.val( AP.page.productId ) : "";

            return false;
        },

        change: function( event ) {
            var thisId = $( event.currentTarget ).val();

            if ( thisId != AP.page.productId && thisId.length ) {
                window.location.href = "/manager/products/" + thisId;
            }

            return false;
        },
    } );


    pub.onDataBound = function( event ) {
        NM.kendo.toggleScrollbar( event ),
        refreshUnlinkedCount();
    };

    pub.init = function() {

        dataSources.items.one( "change", function() {
            fireFilter();
        } );

        kendo.bind( fields.rootDetail, viewModel );

        initSorts();
    };


    var initUpload = function() {
        var images = viewModel.get( "images" );

        var thisUrl = viewModel.get( "currentUploadUrl" );

        NM.util.openModal( fields.imagesModal );

        // it shouldn't be needed "fetch"
        images
            .fetch()
            .then( function() {
                if ( images.total() > 0 ) {

                    for ( var image of images.data() ) {
                        var uid = image.uid;

                        $( "#image-upload-" + uid ).fileupload( {
                            dropZone: $( "#image-upload-dropzone-" + uid ),
                            autoUpload: true,
                            formData: {
                                typeId: image.type.id,
                                imageId: image.id,
                            },
                            url: thisUrl,
                            add: function( event, data ) {
                                var uid = $( event.target ).data( "uid" );

                                var status = $( "#image-upload-status-" + uid );

                                status.html( "" );

                                // TODO: get list form configuration
                                if ( !/\.(jpg|jpeg|png|pdf)$/i.test( data.files[0].name ) ) {
                                    status.html(
                                        "<span class='error'>File non ammesso. Consentiti: jpg, jpeg, png, pdf.</span>",
                                    );
                                    return false;
                                }

                                data.submit();
                            },

                            success: function( event, data ) {
                                // TODO
                                console.log( "success", data );
                            },

                            progressall: function( event, data ) {
                                var status = $( "#image-upload-status-" + uid );
                                status.html( "" );

                                var uid = $( event.target ).data( "uid" );

                                var progress = parseInt( ( data.loaded / data.total ) * 100, 10 );
                                $( "#image-upload-progress-" + uid + " .upload-bar" ).css( "width", progress + "%" );

                                status.html( "Fatto!" );

                                var row = viewModel.get( "images" ).getByUid( uid );

                                setTimeout( () => {
                                    initUpload();
                                }, "1000" );
                            },
                        } );
                    }
                }
            } )
            .catch( ( error ) => {
                console.error( error );
            } );
    };

    var initSorts = function() {
        initItemsSort();
        initAttributesSort();
    };

    var getSortablePlaceholder = function( element ) {
        return element.clone().addClass( "sortable-placeholder" ).height( element.height() )
            .width( element.width() );
    };

    var getSortableHint = function( element ) {
        var ele = $( "<div>" );
        var text = $( element ).find( "td.sortable" ).text();

        ele.text( text ).height( element.height() ).width( element.width() )
            .addClass( "sortable-hint" );

        return ele;
    };

    var refreshDatasources = function() {
        viewModel.get( "items" ).read();
        viewModel.get( "orderingItems" ).read();
        viewModel.get( "orderingAttributes" ).read();
    };

    var sortableChanged = function( entity, widget ) {
        var status = $( ".tab-status" );
        status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

        var items = widget.items();
        var ids = [];

        for ( var item of items ) {
            var id = $( item ).data( "id" );
            ids.push( $( item ).data( "id" ) );
        }

        NM.util.ajax( {
            method: "POST",
            url: "/manager/ajax/products/" + AP.page.productId + "/" + entity + "/order",
            data: JSON.stringify( ids ),
            callback: {
                done: function( xhr ) {
                    refreshDatasources();
                    NM.util.autoHideMessage( status, "<span class='green'>Ordinamento salvato.</span>" );
                },
            },
        } );
    };

    var initItemsSort = function() {
        var table = $( "#product-ordering-items-grid table" );

        table.kendoSortable( {
            axis: "y",
            filter: ">tbody >tr",
            hint: function( element ) {
                return getSortableHint( element );
            },
            placeholder: function( element ) {
                return getSortablePlaceholder( element );
            },

            move: function( event ) {
                var item = {};
                var target = {};

                var itemEle = $( event.item );
                var targetEle = $( event.target );

                var place = $( ".sortable-placeholder" );

                item.attribute = itemEle.data( "attribute" );
                item.level = itemEle.data( "level" );

                target.attribute = targetEle.data( "attribute" );
                target.level = targetEle.data( "level" );

                if ( item.attribute == target.attribute && item.level == target.level ) {
                    place.removeClass( "sortable-placeholder-unavailable" ).addClass( "sortable-placeholder-available" );
                } else {
                    place.removeClass( "sortable-placeholder-available" ).addClass( "sortable-placeholder-unavailable" );
                }

                return;
            },

            change: function() {
                sortableChanged( "items", this );
            },

            end: function( event ) {
                var items = viewModel.get( "orderingItems" );

                var item = items.at( event.oldIndex );
                var target = items.at( event.newIndex );

                if (
                    item.attribute.id != target.attribute.id ||
                    item.level != target.level ||
                    event.newIndex == event.oldIndex
                ) {
                    // you cant
                    console.log( "you can't" );
                    event.preventDefault();
                }

                return;
            },
        } );
    };

    var initAttributesSort = function() {
        var table = $( "#product-ordering-attributes-grid table" );

        table.kendoSortable( {
            axis: "y",
            filter: ">tbody >tr",
            hint: function( element ) {
                return getSortableHint( element );
            },
            placeholder: function( element ) {
                return getSortablePlaceholder( element );
            },

            move: function( event ) {
                var place = $( ".sortable-placeholder" );

                var itemEle = $( event.item );
                var targetEle = $( event.target );

                var itemLevel = itemEle.data( "level" );
                var targetLevel = targetEle.data( "level" );

                if ( itemLevel == targetLevel ) {
                    place.removeClass( "sortable-placeholder-unavailable" ).addClass( "sortable-placeholder-available" );
                } else {
                    place.removeClass( "sortable-placeholder-available" ).addClass( "sortable-placeholder-unavailable" );
                }

                return;
            },

            change: function() {
                sortableChanged( "attributes", this );
            },

            end: function( event ) {
                var items = viewModel.get( "orderingAttributes" );

                var item = items.at( event.oldIndex );

                var target = items.at( event.newIndex );

                if ( item.level != target.level || event.newIndex == event.oldIndex ) {
                    console.log( "can't" );
                    event.preventDefault();
                }

                return;
            },
        } );
    };

    return pub;
} () );
