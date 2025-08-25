AP.namespace( "metadata" );

Object.assign( AP.metadata.fields, {
    detailRoot: $( "#metadata-modal-root" ),
} );

$( document ).ready( function() {
    if ( AP.metadata.fields.detailRoot.length ) {
        AP.metadata.detail.init();
    }
} );

AP.metadata.detail = ( function() {
    var pub = {};

    var fields = AP.metadata.fields;

    var getCurrentConfig = function() {

        var current = viewModel.get( "currentEntity" );

        var baseUrl = "/manager/ajax/";

        var result = {
            modalTitle: "",
            modifyUrl: "",
            readUrl: ""
        };

        if( current ) {

            switch( current.entity ) {

            case "rawValue":

                result.modalTitle = "Metadata per valore base <" + current.value + " >";
                result.readUrl = baseUrl + "raw-values/" + current.value + "/metadata";
                result.modifyUrl = result.readUrl;

                break;

            default:
            }

        }

        return result;

    };

    function applyValidationRules() {

        var metadata = viewModel.get( "rows" ).data();

        var validator = $( "#metadata-detail-form" ).validate();

        // Rimuove tutte le regole e messaggi prima di applicarne di nuovi
        validator.settings.rules = {};
        validator.settings.messages = {};

        metadata.forEach( item => {

            const fieldName = `metadata_${item.type.code}`;
            const rules = {};
            const messages = {};

            switch ( item.type.dataType.id ) {

            case "INTEGER":
                rules.digits = true;
                messages.digits = `Inserisci un numero intero valido per ${item.type.name}.`;
                break;

            case "DECIMAL":
                rules.number = true;
                messages.number = `Inserisci un numero decimale valido per ${item.type.name}.`;
                break;

            case "DATE":
                rules.date = true; // Utilizza la regola built-in di jQuery Validation
                messages.date = `Inserisci una data valida per ${item.name}.`;
                break;

            case "STRING":
                break;

            case "TEXT":
                break;

            case "BOOLEAN":
                // La regola 'required' per una checkbox garantisce che sia spuntata
                break;
            }

            validator.settings.rules[fieldName] = rules;
            validator.settings.messages[fieldName] = messages;
        } );
    }

    var dataSource = new kendo.data.DataSource();

    dataSource.bind( "change", function( event ) {
        console.log( "event", event );
        applyValidationRules();
    } );

    var viewModel = kendo.observable( {
        rows: dataSource,
        currentEntity: undefined,

        callbacks: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        search: function( event ) {
            var thisForm = AP.metadata.fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

        getTitle: function( event ) {

            var config = getCurrentConfig();

            return config.modalTitle;
        },

        save: function( event ) {

            var config = getCurrentConfig();
            var data = viewModel.get( "rows" ).data();
            var thisForm = $( "#metadata-detail-form" );
            var status = thisForm.find( ".status" );

            console.log( "status", status );

            if ( thisForm.valid() ) {

                NM.util.ajax( {
                    method: "POST",
                    url: config.modifyUrl,
                    data: JSON.stringify( data ),
                    callback: {
                        done: function( xhr ) {

                            NM.util.autoHideMessage( status, "<span class='green'>Metadati aggiornati</span>" );

                            setTimeout( function() {
                                fields.detailRoot.modal( "hide" ),
                                AP.util.fireCallback( "onSave", viewModel.get( "callback" ) );
                            }, 600 );

                        },
                    },
                } );

            }

            return false;
        },

    } );

    pub.open = function( entity, onSave ) {

        viewModel.set( "currentEntity", entity );
        viewModel.set( "callback.onSave", onSave );

        var config = getCurrentConfig();

        NM.util.ajax( {
            method: "GET",
            url: config.readUrl,
            callback: {
                done: function( xhr ) {

                    viewModel.get( "rows" ).data( xhr.data );

                    NM.util.openModal( $( "#metadata-modal-root" ) );
                },
            },
        } );

    };

    pub.init = function() {

        kendo.bind( AP.metadata.fields.detailRoot, viewModel );

    };

    return pub;
} () );


