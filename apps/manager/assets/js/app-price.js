AP.namespace( "price" );

Object.assign( AP.price.fields, {
    modal: $( "#price-form-list-modal" ),
    modalForm: $( "#price-form-list-modal-form" ),
} );

AP.price.modal = ( function() {

    var pub = {};
    var fields = AP.price.fields;

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

            case "product":

                result.modalTitle = "Prezzi per l'articolo: " + current.line.name + " / " + current.model.name + " / " + current.finish.name;
                result.readUrl = baseUrl + "/products/" + current.id + "/prices";
                result.modifyUrl = result.readUrl;

                break;

            case "productItem": // productItem

                result.modalTitle = "Prezzi per l'attributo: " + current.attribute.name + " / " + current.attributeValue.rawValue.name;
                result.readUrl = baseUrl + "/product-items/" + current.item.id + "/prices";
                result.modifyUrl = result.readUrl;

                break;

            default:
                throw Error( "ERROR. Type not managed: " + current.type );
            }

        }

        return result;

    };


    // var prices = new kendo.data.DataSource();
    var prices = new kendo.data.DataSource( { data: [] } );

    var viewModel = kendo.observable( {

        currentItem: { type: "", id: "" }, // all object with type, id, line, model, attribute, attributeValue
        prices: prices,
        methods: AP.page.methods, // from ProductController

        callbacks: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined
        },


        title: function( event ) {
            return getCurrentConfig().modalTitle;
        },

        save: function( event ) {

            var modal = fields.modal;
            var modalForm = fields.modalForm;
            var status = modalForm.find( ".status" );

            modalForm.validate( {
                onfocusout: function( element ) {
                    $( element ).valid();
                },
            } );


            // thisForm.valid();
            if ( true ) {

                status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

                NM.util.ajax( {
                    method: "POST",
                    url: getCurrentConfig().modifyUrl,
                    data: JSON.stringify( { prices: viewModel.get( "prices" ).data(), item: viewModel.get( "currentItem" ) } ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                AP.widget.notify( "success", "Prezzi salvati con successo" );
                                status.html( "" );

                                setTimeout( () => {
                                    modal.modal( "hide" );
                                    AP.util.fireCallback( "onUpdate", viewModel.get( "callbacks" ) );
                                }, 1000 );

                            }
                        },
                    },
                } );
            }

            return false;

        }

    } );

    var loadList = function( productId ) {

        NM.util.ajax( {
            method: "GET",
            url: getCurrentConfig().readUrl,
            callback: {
                done: function( xhr ) {

                    viewModel.get( "prices" ).data( xhr.data );

                    NM.util.openModal( fields.modal );

                },
            },
        } );

    };

    pub.open = function( item, onUpdate ) {

        if( onUpdate ) {
            viewModel.set( "callbacks.onUpdate", onUpdate );
        }

        viewModel.set( "currentItem", item );

        loadList();

        kendo.bind( fields.modal, viewModel );

    };

    return pub;
}() );
