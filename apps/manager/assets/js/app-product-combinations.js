AP.product = AP.product || {};
AP.fields.combination = AP.fields.combination || {};

AP.fields.combination = {
    listRoot: $( "#product-combinations-root" ),
    listForm: $( "#product-combinations-form" ),
    imagesModal: $( "#product-images-list-modal" ),
    searchForm: $( "#product-combinations-search-form" ),
};

$( document ).ready( function() {
    if ( AP.fields.combination.listRoot.length ) {
        AP.product.combination.init();
    }
} );

AP.product.combination = ( function() {
    var pub = {};

    var fields = AP.fields.combination;

    var dataSources = {
        items: NM.kendo.dataSource( {
            url:
                "/manager/ajax/products/" + AP.page.productId + "/combinations",
        } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            var thisForm = fields.searchForm;
            var params = thisForm.serializeJSON();
            var filters = [];

            console.log( "params", params );

            var dataSource = viewModel.get( "rows" );

            var filterDataSource = new kendo.data.DataSource( {
                data: dataSource.data().toJSON(),
            } );

            if ( params.statusId.length ) {
                filters.push( {
                    field: "status.id",
                    operator: "equal",
                    value: params.statusId,
                } );
            }

            if ( params.str.length ) {
                filters.push( {
                    field: "name",
                    operator: "contains",
                    value: params.str,
                } );
            }

            filterDataSource.filter( filters );

            viewModel.set( "rows", filterDataSource );

            return false;
        },

        /*
				getImageTypeText: function (event) {
					var text = AP.util.getMainText(event.type.texts.toJSON());

					return text.name + " " + event.shortId;
				},

				getImageSrc: function (event) {
					var uri = event.uri;

					if (event.uri != "") {
						var replaced = uri.replace("_ori", "500");

						return replaced;
					}

					return "/assets/main/img/img-not-found.png";
				},

				getImageHref: function (event) {
					var uri = event.uri;

					if (event.uri != "") {
						return uri;
					}

					// TODO: not work with target=_blank
					return "javascript:void(0)";
				},
				*/

        calculate: function( event ) {
            var id = event.data.id;
            var thisList = AP.fields.combination.listRoot;

            var status = thisList.find( ".status" );
            status.html(
                "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>",
            );

            NM.util.ajax( {
                method: "GET",
                url:
                    "/manager/ajax/products/" +
                    AP.page.productId +
                    "/combinations/calculate",
                callback: {
                    done: function( xhr ) {
                        AP.widget.notify(
                            "success",
                            "Combinazioni generate con successo.",
                            "Ok!",
                        );
                        viewModel.rows.read();
                    },
                },
            } );
            return false;
        },

        delete: function( event ) {
            var checks = fields.listForm.find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url:
                        "/manager/ajax/products/" +
                        AP.page.productId +
                        "/combinations",
                    data: ids,
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                                AP.widget.notify(
                                    "error",
                                    "Non riesco a cancellare tutte le combinazioni",
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
                AP.widget.notify(
                    "warning",
                    "Seleziona almeno una combinazione",
                );
            }
        },

        openImagesList: function( event ) {
            var element = $( event.currentTarget );
            var id = event.data.id;

            if ( !element.attr( "data-type" ) ) {
                console.error(
                    "ERROR. Set data-type attribute in currentTarget",
                );
                return;
            }

            var type = element.data( "type" );

            switch ( type ) {
            case "combination":
                var value = {
                    type: "combination",
                    id: id,
                };

                var thisUrl =
                        "/manager/ajax/combinations/" + id + "/images";

                break;

            default:
                console.error(
                    "ERROR. Type [" + type + "] for image not found",
                );
            }

            var dataSource = NM.kendo.dataSource( { url: thisUrl } );

            viewModel.set( "currentImageEntity", value );
            viewModel.set( "currentUploadUrl", thisUrl );
            if ( dataSource ) {
                viewModel.set( "images", dataSource );
            }

            initUpload();

            return false;
        },
    } );

    pub.init = function() {
        kendo.bind( AP.fields.combination.listRoot, viewModel );
    };

    // TODO: implement an only one "initUpload()"
    var initUpload = function() {
        var images = viewModel.get( "images" );

        var thisUrl = viewModel.get( "currentUploadUrl" );

        NM.util.openModal( AP.fields.combination.imagesModal );

        images
            .fetch()
            .then( function() {
                if ( images.total() > 0 ) {
                    // console.log("total:in", images.total() );

                    for ( var image of images.data() ) {
                        var uid = image.uid;

                        // console.log( "image", image );

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
                                if (
                                    !/\.(jpg|jpeg|png|pdf)$/i.test(
                                        data.files[0].name,
                                    )
                                ) {
                                    status.html(
                                        "<span class='error'>File non ammesso. Consentiti: jpg, jpeg, png, pdf.</span>",
                                    );
                                    return false;
                                }

                                data.submit();
                            },

                            success: function( event, data ) {
                                // TODO
                                console.log( "success" );
                                console.log( "success", data );
                            },

                            progressall: function( event, data ) {
                                var status = $( "#image-upload-status-" + uid );
                                status.html( "" );

                                var uid = $( event.target ).data( "uid" );

                                var progress = parseInt(
                                    ( data.loaded / data.total ) * 100,
                                    10,
                                );
                                $( "#image-upload-progress-" + uid + " .upload-bar", ).css( "width", progress + "%" );

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

    return pub;
} () );
