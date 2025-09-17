AP.namespace( "file" );

Object.assign( AP.file.fields, {
    modal: $( "#files-list-modal" ),
} );


$( document ).ready( function() {
    if ( AP.file.fields.modal.length ) {
        // AP.file.modal.init();
    }
} );

AP.file.modal = ( function() {
    var pub = {};

    var fields = AP.file.fields;

    var getCurrentConfig = function() {

        var current = viewModel.get( "currentItem" );
        var baseUrl = "/manager/ajax";

        var result = {
            modalTitle: "",
            modifyUrl: "",
            readUrl: ""
        };

        if( current ) {

            switch( current.type ) {

            case "productItem": // productItem

                result.modalTitle = "File per l'item < " + current.name + " >";
                result.readUrl = baseUrl + "/product-items/" + current.id + "/images";
                result.modifyUrl = result.readUrl;


                break;

            case "product":

                result.modalTitle = "File per il prodotto: <" + current.name.substr( current.name.length - 5 ) + " >";
                result.readUrl = baseUrl + "/products/" + current.id + "/images";
                result.modifyUrl = result.readUrl;

                break;

            case "attributeValue":

                result.modalTitle = "File per il valore: <" + current.name + " >";
                result.readUrl = baseUrl + "/attributes-values/" + current.id + "/images";
                result.modifyUrl = result.readUrl;

                break;

            default:
            }

        }

        return result;

    };

    var viewModel = kendo.observable( {
        files: new kendo.data.DataSource( { data: [] } ),
        currentItem: undefined,

        title: function( event ) {

            return getCurrentConfig().modalTitle;

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

        delete: function( event ) {

            var uid = event.data.uid;

            var linked = $( "#img-linked-" + uid );
            var loading = $( "#img-linked-loading-" + uid );

            linked.addClass( "d-none" );
            loading.removeClass( "d-none" );

            loading.html( "<img src='/assets/main/img/ajax-loading.svg' width='40' height='40'>" );

            NM.util.ajax( {
                method: "DELETE",
                url: "/manager/ajax/products/" + event.data.id + "/images",
                callback: {
                    done: function( xhr ) {

                        setTimeout( () => {
                            loading.html( "" );
                            linked.removeClass( "d-none" );

                            initUpload();
                        }, 800 );

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

        /*
        list: function( event ) {
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

                var thisUrl = "/manager/ajax/combinations/" + id + "/images";

                break;

            default:
                console.error( "ERROR. Type [" + type + "] for image not found" );
            }

            var dataSource = NM.kendo.dataSource( { url: thisUrl } );

            viewModel.set( "currentImageEntity", value );
            viewModel.set( "currentUploadUrl", thisUrl );

            if ( dataSource ) {
                viewModel.set( "files", dataSource );
            }


        },
		*/
    } );

    pub.open = function( item ) {

        kendo.bind( fields.modal, viewModel );

        // console.log( "item", item );
        // console.log( "fields.modal", fields.modal );

        viewModel.set( "currentItem", item );

        var config = getCurrentConfig();

        NM.util.ajax( {
            method: "GET",
            url: config.readUrl,
            callback: {
                done: function( xhr ) {
                    viewModel.get( "files" ).data( xhr.data );
                    initUpload();
                }
            }
        } );

        // NM.util.openModal( fields.modal );

    };


    pub.init = function() {
        console.log( "AP.file.modal.init" );
    };

    // TODO: implement an only one "initUpload()"
    var initUpload = function() {

        var config = getCurrentConfig();

        var files = viewModel.get( "files" );
        var thisUrl = config.modifyUrl;

        NM.util.openModal( fields.modal );

        files
            .fetch()
            .then( function() {
                if ( files.total() > 0 ) {
                    // console.log("total:in", images.total() );

                    for ( var file of files.data() ) {
                        var uid = file.uid;

                        // console.log( "file", file );

                        $( "#file-upload-" + uid ).fileupload( {
                            dropZone: $( "#file-upload-dropzone-" + uid ),
                            autoUpload: true,
                            formData: {
                                typeId: file.type.id,
                                fileId: file.id,
                            },
                            url: thisUrl,
                            add: function( event, data ) {
                                var uid = $( event.target ).data( "uid" );

                                var status = $( "#file-upload-status-" + uid );

                                status.html( "" );

                                // TODO: get list form configuration
                                if (
                                    !/\.(jpg|jpeg|png|pdf|svg)$/i.test(
                                        data.files[0].name,
                                    )
                                ) {
                                    status.html( "<span class='error'>File non ammesso. Consentiti: jpg, jpeg, png, pdf, svg.</span>" );
                                    return false;
                                }

                                console.log( "upload:data", data );

                                data.submit();
                            },

                            success: function( event, data ) {
                                // TODO
                                console.log( "success", data );
                            },

                            progressall: function( event, data ) {
                                var status = $( "#file-upload-status-" + uid );
                                status.html( "" );

                                var uid = $( event.target ).data( "uid" );

                                var progress = parseInt(
                                    ( data.loaded / data.total ) * 100,
                                    10,
                                );
                                $( "#file-upload-progress-" + uid + " .upload-bar", ).css( "width", progress + "%" );

                                status.html( "Fatto!" );

                                var row = viewModel.get( "files" ).getByUid( uid );

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
