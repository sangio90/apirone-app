AP.text = AP.text || {};

AP.text.fields = {
    listRoot   : $( "#text-list-root" ),
    listSearch : $( "#text-search-form" ),
    detailModal: $( "#text-detail-modal" )
};

$( document ).ready( function(){

    if ( AP.text.fields.listRoot.length ) {

	    AP.text.list.init();

    }

} );

AP.text.list = ( function() {

    var pub = {};

    var viewModel = kendo.observable( {

        rows: undefined,

        detailForm: {
            data: {
                texts: undefined
            },
            title: "Traduzione",
            labelButton: "Salva"
        },

        isTranslated: function( event ) {
            if ( event.status.id == "TRA" ) {
                return true;
            }

            return false;
        },

        isUntranslated: function( event ) {
            if ( event.status.id == "TOT" ) {
                return true;
            }

            return false;
        },

        edit: function( event ) {

            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/texts/" + event.data.id + "/all",
                callback: {
                    done: function( xhr ) {

                        viewModel.set( "detailForm.data.texts", xhr.data );
                        NM.util.openModal( AP.text.fields.detailModal );

                    }
                }
            } );

            return false;

        },

        print: function( item ) {

            window.open( "/manager/lines/print", "_blank" );

            return false;
        },

        search: function() {

            var qs = AP.text.fields.listSearch.serialize();

            var dataSource = NM.kendo.dataSource( { url: "/manager/ajax/texts?" + qs } );

            viewModel.set( "rows", dataSource );

            return false;

        },

        save: function( event ) {

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/texts",
                data: JSON.stringify( viewModel.get( "detailForm.data.texts" ) ),
                callback: {
                    done: function( xhr ) {

                        AP.widget.notify( "success", "Traduzione salvata successo" );

                        setTimeout( () => {

                            $( "#text-detail-modal" ).modal( "hide" );
                            window.location.href = window.location.pathname+"?"+$.param( { "reset":1, "fwreinit":1 } );


                        }, 1000 );
                    }
                }
            } );

            return false;

        },

        createTraduzioniMancanti: function( event ) {
            const traduzioni = event.data.detailForm.data.texts
            const requiredLangs = ["IT","EN","FR","ES","DE"];

            const allPresent = requiredLangs.every(req =>
                traduzioni.some(item => item.lang.id === req)
            );

            if (allPresent) {
                AP.widget.notify( "warning", "Le cinque traduzioni sono già presenti." );
                return false;
            }

            NM.util.ajax( {
                method: "GET",
                url: `/manager/ajax/texts_createtraduzionimancanti/${traduzioni[0].id}`,
                callback: {
                    done: function( xhr ) {
                        AP.widget.notify( "success", "Traduzioni mancanti aggiunte con successo" );
                        setTimeout( () => {
                            window.location.href = window.location.pathname+"?"+$.param( { "reset":1, "fwreinit":1 } );
                        }, 500 );
                    }
                }
            } );

            return false;

        }


    } );


    pub.init = function() {

        kendo.bind( AP.text.fields.listRoot, viewModel );

        viewModel.search();

    };

    return pub;
}() );
