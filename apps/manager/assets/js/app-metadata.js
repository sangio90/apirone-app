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

    function attachRules() {

        var rows = viewModel.get("rows").data();

        for (var row in rows ) {
            
            switch ( row.type.dataType ) {
                case "INTEGER":
                row.set("validation.rule") = digits;
                row.set("validation.msg") = `Inserisci un numero intero valido per "${item.name}".`;
                break;

            case "DECIMAL":
                rules.number = true;
                messages.number = `Inserisci un numero decimale valido per "${item.name}".`;
                if ( item.min !== undefined ) { rules.min = item.min; }
                if ( item.max !== undefined ) { rules.max = item.max; }
                break;

            case "DATE":
                rules.date = true; // Utilizza la regola built-in di jQuery Validation
                messages.date = `Inserisci una data valida per "${item.name}".`;
                break;

            case "STRING":
                if ( item.minLength !== undefined ) { rules.minlength = item.minLength; }
                if ( item.maxLength !== undefined ) { rules.maxlength = item.maxLength; }
                break;

            case "TEXT":
                if ( item.minLength !== undefined ) { rules.minlength = item.minLength; }
                if ( item.maxLength !== undefined ) { rules.maxlength = item.maxLength; }
                break;

            case "BOOLEAN":
                // La regola 'required' per una checkbox garantisce che sia spuntata
                break;
            }

        } ;

    }

    function applyMetadataValidation( metadata ) {
        // Rimuove tutte le regole e messaggi prima di applicarne di nuovi
        validator.settings.rules = {};
        validator.settings.messages = {};

        // Aggiunge la regola per il campo standard del prodotto
        // formValidator.settings.rules["product-name"] = { required: true };
        validator.settings.messages["product-name"] = { required: "Il nome del prodotto è obbligatorio." };

        metadata.forEach( item => {
            const fieldName = `metadata_${item.code}`;
            const rules = {};
            const messages = {};

            if ( item.required ) {
                rules.required = true;
                messages.required = `Il campo "${item.name}" è obbligatorio.`;
            }

            switch ( item.dataType ) {
            case "INTEGER":
                rules.digits = true;
                messages.digits = `Inserisci un numero intero valido per "${item.name}".`;
                if ( item.min !== undefined ) { rules.min = item.min; }
                if ( item.max !== undefined ) { rules.max = item.max; }
                break;

            case "DECIMAL":
                rules.number = true;
                messages.number = `Inserisci un numero decimale valido per "${item.name}".`;
                if ( item.min !== undefined ) { rules.min = item.min; }
                if ( item.max !== undefined ) { rules.max = item.max; }
                break;

            case "DATE":
                rules.date = true; // Utilizza la regola built-in di jQuery Validation
                messages.date = `Inserisci una data valida per "${item.name}".`;
                break;

            case "STRING":
                if ( item.minLength !== undefined ) { rules.minlength = item.minLength; }
                if ( item.maxLength !== undefined ) { rules.maxlength = item.maxLength; }
                break;

            case "TEXT":
                if ( item.minLength !== undefined ) { rules.minlength = item.minLength; }
                if ( item.maxLength !== undefined ) { rules.maxlength = item.maxLength; }
                break;

            case "BOOLEAN":
                // La regola 'required' per una checkbox garantisce che sia spuntata
                break;
            }

            validator.settings.rules[fieldName] = rules;
            validator.settings.messages[fieldName] = messages;
        } );
    }

    var dataSource = new kendo.data.DataSource()

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
            return "Titolo";
        },

        save: function( event ) {
            var checks = $( "#metadata-type-grid" ).find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/metadata-types",
                    data: ids,
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                                AP.widget.notify(
                                    "error",
                                    "Non riesco a cancellare tutti i valori",
                                );
                            } else {
                                AP.widget.notify(
                                    "success",
                                    "Cancellazione avvenuta con successo",
                                );
                            }

                            var id = viewModel.get( "detailForm.data.id" );
                            console.log( "id", id );

                            viewModel.rows.read();
                        },
                    },
                } );
            } else {
                AP.widget.notify( "warning", "Seleziona almeno un valore" );
            }
        },

    } );

    pub.open = function( entity, onSave ) {

        viewModel.set( "currentEntity", entity );
        viewModel.set("callback.onSave", onSave);
        
        console.log("entity", entity)

        // viewModel.showList();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/raw-values/" + entity.value + "/metadata",
            //data: { entity: entity.entity, value: entity.value },
            callback: {
                done: function (xhr) {

                    var newData = [];

                    var data = new kendo.data.DataSource( xhr.data );
                    
                    console.log("data", data)

                    for (var item in data.data()) {
                        
                        console.log("item", item)

                        switch (item.type.dataType) {
                            case "INTEGER":
                                item.set("validation.rule") = digits;
                                item.set("validation.msg") = `Inserisci un numero intero valido per "${item.name}".`;
                                break;
                            
                        }
                        newData.push( item )

                    }

                    console.log("newData", newData);
                    

                    viewModel.set("rows", xhr.data);
                    
                    console.log("-xx", viewModel.get("rows"))

                    NM.util.openModal( $( "#metadata-modal-root" ) );
                },
            },
        } );

    };

    pub.init = function () {
        
        console.log("AP.metadata.fields.detailRoot", AP.metadata.fields.detailRoot)
        console.log("viewModel", viewModel)

        kendo.bind( AP.metadata.fields.detailRoot, viewModel );

        //var validator = $( "#metadata-detail-form" ).validate( {} );

    };

    return pub;
} () );


