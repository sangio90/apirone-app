AP.namespace( "file" );

Object.assign( AP.file.fields, {
    modal: $( "#files-list-modal" ),
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

            case "combination":

                result.modalTitle = "File per la combinazione: <" + current.name.substr( current.name.length - 5 ) + " >";
                result.readUrl = baseUrl + "/combinations/" + current.id + "/images";
                result.modifyUrl = result.readUrl;

                break;

            case "quotationItem":

                result.modalTitle = "File per la riga di preventivo: <" + current.name.substr( current.name.length - 5 ) + " >";
                result.readUrl = baseUrl + "/quotation-items/" + current.id + "/images";
                result.modifyUrl = result.readUrl;

                break;

            case "quotationZone":
                const zoneName = current.origin ? current.origin + " - " + current.name : current.name
                result.modalTitle = "File per la piante della zona: < " + zoneName + " >";
                result.readUrl = baseUrl + "/quotation-zones/" + current.id + "/images";
                result.modifyUrl = result.readUrl;

                break;

            default:
                throw Error( "ERROR. Type not managed: " + current.type );
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

            const uri = event.uri || "";

            if ( uri.toLowerCase().endsWith( ".svg" ) ) {
                return uri;
            }

            if ( uri != "" )  {
                var replaced = uri.replace( "_ori", "500" );
                return replaced;
            }

            return "/assets/main/img/img-not-found.png";
        },

        delete: function( event ) {

            var uid = event.data.uid;

            var linked = $( "#file-linked-" + uid );
            var loading = $( "#file-linked-loading-" + uid );

            linked.addClass( "d-none" );
            loading.removeClass( "d-none" );

            loading.html( "<img src='/assets/main/img/ajax-loading.svg' width='40' height='40'>" );

            NM.util.ajax( {
                method: "DELETE",
                url: "/manager/ajax/files/" + event.data.id,
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

    } );

    pub.open = function( item ) {

        kendo.bind( fields.modal, viewModel );

        viewModel.set( "currentItem", item );

        initUpload();

    };

    pub.init = function() {
        console.log( "AP.file.modal.init" );
    };

    // TODO: implement an only one "initUpload()"
    var initUpload = function() {

        var config = getCurrentConfig();

        NM.util.ajax( {
            method: "GET",
            url: config.readUrl,
            callback: {
                done: function( xhr ) {
                    viewModel.get( "files" ).data( xhr.data );

                    var files = viewModel.get( "files" );
                    var modifyUrl = config.modifyUrl;

                    NM.util.openModal( fields.modal );

                    files
                        .fetch()
                        .then( function() {
                            if ( files.total() > 0 ) {

                                for ( var file of files.data() ) {
                                    var uid = file.uid;

                                    $( "#file-upload-" + uid ).fileupload( {
                                        dropZone: $( "#file-upload-dropzone-" + uid ),
                                        autoUpload: true,
                                        formData: {
                                            typeId: file.type.id,
                                            fileId: file.id,
                                        },
                                        url: modifyUrl,
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

                                            data.submit();
                                        },

                                        success: function( event, data ) {
                                            //questo caso capita quando sto selezionando un'immagine custom per un quotation item. In questa occasione
                                            //l'unico modo per avere nel riquadro della preview l'immagine aggiornata è ricaricare la pagina, percheé
                                            //per come è definito questo componente, non riesco a trasmettere alla quotation item modal il path
                                            //della nuova immagine caricata. 
                                            if (viewModel.get('currentItem') && viewModel.get('currentItem.type') == 'quotationItem') {
                                                const params = new URLSearchParams(window.location.search);

                                                if (!params.has("reset")) {
                                                    params.set("reset", 1);
                                                    window.location.search = params.toString();
                                                } else {
                                                    window.location.reload()
                                                }
                                            }
                                            console.log( "success", data );
                                        },

                                        progressall: function( event, data ) {

                                            var uid = $( event.target ).data( "uid" );

                                            var status = $( "#file-upload-status-" + uid );

                                            status.html( "" );

                                            var progress = parseInt( ( data.loaded / data.total ) * 100, 10, );

                                            $( "#file-upload-progress-" + uid + " .upload-bar", ).css( "width", progress + "%" );

                                            status.html( "Fatto!" );

                                            var row = viewModel.get( "files" ).getByUid( uid );

                                            setTimeout( () => {
                                                initUpload();
                                            }, 800 );
                                        },
                                    } );
                                }
                            }
                        } )
                        .catch( ( error ) => {
                            console.error( error );
                        } );
                }
            }
        } );

    };

    return pub;
} () );
