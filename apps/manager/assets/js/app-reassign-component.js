AP.namespace( "reassignComponent" );

Object.assign( AP.reassignComponent.fields, {
    reassignComponentForm: $( "#reassign-component-form" ),
    deleteComponentForm: $( "#delete-component-form" )
} );

$( document ).ready( function(){
    if ( AP.reassignComponent.fields.reassignComponentForm.length ) {
        AP.reassignComponent.ressignForm.init();
    }
    if ( AP.reassignComponent.fields.deleteComponentForm.length ) {
        AP.reassignComponent.deleteForm.init();
    }
} );

AP.reassignComponent.ressignForm = ( function() {

    var pub = {};

    var viewModel = kendo.observable( {
        category: "",
        oldParam: null,
        newParam: null,
        save: function( event ) {
            event.preventDefault();

            var category = viewModel.get('category')
            var oldParam = viewModel.get('oldParam')
            var newParam = viewModel.get('newParam')

            if (category == null || category == '') {
                AP.widget.notify( "warning", "Imposta la categoria." );
                return false;
            }
            if (oldParam == null || oldParam == '') {
                AP.widget.notify( "warning", "Imposta il vecchio parametro." );
                return false;
            }
            if (newParam == null || newParam == '') {
                AP.widget.notify( "warning", "Imposta il nuovo parametro." );
                return false;
            }

            var categoryString = '';
            if (category == 'rawProductId') {
                categoryString = 'Prodotto';
            }
            if (category == 'colorId') {
                categoryString = 'Colore';
            }
            if (category == 'variantId') {
                categoryString = 'Variante';
            }
            bootbox.confirm( {
                title: "Conferma riassegnazione",
                message: "Sei sicuro di voler riassegnare i componenti da <b>" + categoryString + "</b> <b>" + viewModel.get('oldParam') + "</b> a <b>" + categoryString + "</b> <b>" + viewModel.get('newParam') + "</b>?",
                buttons: {
                    confirm: {
                        label: "Si, confermo",
                        className: "btn-primary",
                    },
                    cancel: {
                        label: "No, chiudi",
                        className: "btn-danger",
                    },
                },
                callback: function( result ) {
                    if ( result ) {
                        NM.util.ajax( {
                            method: "POST",
                            url: "/manager/ajax/components/reassign",
                            data: {
                                'category': viewModel.get('category'),
                                'oldParam': viewModel.get('oldParam'),
                                'newParam': viewModel.get('newParam'),
                            },
                            callback: {
                                done: function( xhr ) {
                                    if( xhr.status == "SUCCESS" ) {
                                        //AP.widget.notify( "success", xhr.data.message );
                                        viewModel.set('category', '');
                                        viewModel.set('oldParam', null);
                                        viewModel.set('newParam', null);
                                        $("#reassignResultMessage").attr("style", "color: green; font-weight: bold; font-size: 18px;");
                                        $('#reassignResultMessage').text(xhr.data.message);
                                        setTimeout(function() {
                                            $("#reassignResultMessage").empty();
                                        }, 5000);
                                    }
                                    if ( xhr.status == "ERRORE" ) {
                                        //AP.widget.notify( "error", xhr.data.error );
                                        $("#reassignResultMessage").attr("style", "color: red; font-weight: bold; font-size: 18px;");
                                        $('#reassignResultMessage').text(xhr.data.error);
                                        setTimeout(function() {
                                            $("#reassignResultMessage").empty();
                                        }, 5000);
                                    }

                                }
                            }
                        } );
                    } else {
                        viewModel.set('category', '');
                        viewModel.set('oldParam', null);
                        viewModel.set('newParam', null);
                    }
                },
            } );

            return false;
        },
    } );

    pub.init = function() {
        kendo.bind( AP.reassignComponent.fields.reassignComponentForm, viewModel );
    };

    return pub;

}() );

AP.reassignComponent.deleteForm = ( function() {

    var pub = {};

    var viewModel = kendo.observable( {
        category: "",
        oldParam: null,
        delete: function( event ) {
            event.preventDefault();
            var category = viewModel.get('category')
            var oldParam = viewModel.get('oldParam')

            if (category == null || category == '') {
                AP.widget.notify( "warning", "Imposta la categoria." );
                return false;
            }
            if (oldParam == null || oldParam == '') {
                AP.widget.notify( "warning", "Imposta il parametro." );
                return false;
            }
            
            var categoryString = '';
            if (category == 'rawProductId') {
                categoryString = 'Prodotto';
            }
            if (category == 'colorId') {
                categoryString = 'Colore';
            }
            if (category == 'variantId') {
                categoryString = 'Variante';
            }

            bootbox.confirm( {
                title: "Conferma eliminazione",
                message: "Sei sicuro di voler cancellare i componenti con <b>" + categoryString + "</b> uguale a <b>" + viewModel.get('oldParam') + "</b>?",
                buttons: {
                    confirm: {
                        label: "Si, confermo",
                        className: "btn-primary",
                    },
                    cancel: {
                        label: "No, chiudi",
                        className: "btn-danger",
                    },
                },
                callback: function( result ) {
                    if ( result ) {
                        NM.util.ajax( {
                            method: "DELETE",
                            url: "/manager/ajax/components/delete",
                            data: {
                                'category': viewModel.get('category'),
                                'oldParam': viewModel.get('oldParam')
                            },
                            callback: {
                                done: function( xhr ) {
                                    if( xhr.status == "SUCCESS" ) {
                                        //AP.widget.notify( "success", xhr.data.message );
                                        viewModel.set('category', '');
                                        viewModel.set('oldParam', null);
                                        $("#deleteResultMessage").attr("style", "color: green; font-weight: bold; font-size: 18px;");
                                        $('#deleteResultMessage').text(xhr.data.message);
                                        setTimeout(function() {
                                            $("#deleteResultMessage").empty();
                                        }, 5000);
                                    }
                                    if ( xhr.status == "ERRORE" ) {
                                        //AP.widget.notify( "error", xhr.data.error );
                                        $("#deleteResultMessage").attr("style", "color: red; font-weight: bold; font-size: 18px;");
                                        $('#deleteResultMessage').text(xhr.data.error);
                                        setTimeout(function() {
                                            $("#deleteResultMessage").empty();
                                        }, 5000);
                                    }

                                }
                            }
                        } );
                    } else {
                        viewModel.set('category', '');
                        viewModel.set('oldParam', null);
                    }
                },
            } );

            return false;
        },
    } );

    pub.init = function() {
        kendo.bind( AP.reassignComponent.fields.deleteComponentForm, viewModel );
    };

    return pub;

}() );