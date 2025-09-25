AP.namespace( "reassignComponent" );

Object.assign( AP.reassignComponent.fields, {
    reassignComponentForm: $( "#reassign-component-form" )
} );

$( document ).ready( function(){
    if ( AP.reassignComponent.fields.reassignComponentForm.length ) {
        AP.reassignComponent.form.init();
    }
} );

AP.reassignComponent.form = ( function() {

    var pub = {};

    var viewModel = kendo.observable( {
        category: null,
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

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/reassign-components",
                data: {
                    'category': viewModel.get('category'),
                    'oldParam': viewModel.get('oldParam'),
                    'newParam': viewModel.get('newParam'),
                },
                callback: {
                    done: function( xhr ) {
                        if( xhr.status == "SUCCESS" ) {
                            //AP.widget.notify( "success", xhr.data.message );
                            $("#resultMessage").attr("style", "color: green; font-weight: bold; font-size: 18px;");
                            $('#resultMessage').text(xhr.data.message);
                            setTimeout(function() {
                                $("#resultMessage").empty();
                            }, 5000);
                        }
                        if ( xhr.status == "ERRORE" ) {
                            //AP.widget.notify( "error", xhr.data.error );
                            $("#resultMessage").attr("style", "color: red; font-weight: bold; font-size: 18px;");
                            $('#resultMessage').text(xhr.data.error);
                            setTimeout(function() {
                                $("#resultMessage").empty();
                            }, 5000);
                        }

                    }
                }
            } );

            return false;
        },
    } );

    pub.init = function() {
        kendo.bind( AP.reassignComponent.fields.reassignComponentForm, viewModel );
    };

    return pub;

}() );