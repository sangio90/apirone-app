if ( localStorage.getItem( "sidebar-left-position" ) !== null ) {
    var initialPosition = localStorage.getItem( "sidebar-left-position" );
    var sidebarLeft = document.querySelector( "#sidebar-left .nano-content" );

    if ( sidebarLeft ) {
        sidebarLeft.scrollTop = initialPosition;
    }

}

// the overlay shows above the first modal, not in the back.
// https://stackoverflow.com/questions/19305821/multiple-modals-overlay
$( document ).on( "show.bs.modal", ".modal", function() {
    const zIndex = 1040 + ( 10 * $( ".modal:visible" ).length );
    $( this ).css( "z-index", zIndex );
    setTimeout( () => $( ".modal-backdrop" )
        .not( ".modal-stack" )
        .css( "z-index", zIndex - 1 )
        .addClass( "modal-stack" ) );
} );

if ( localStorage.getItem( "sidebar-left-collapsed" ) == "true" ) {

    document.getElementsByTagName( "html" )[0]
        .classList.add( "sidebar-left-collapsed" );

} else {

    document.getElementsByTagName( "html" )[0]
        .classList.remove( "sidebar-left-collapsed" );

}

var setSidebarHeight = function() {
    // set the sidebar height
    var nano = $( "#sidebar-left .nano" );
    nano.height( $( window ).height() );
};

function highlightTabWithError( fieldName ) {
    var input = $( "[name=\"" + fieldName + "\"]" );
    var tabPane = input.closest( ".tab-pane" );
    var tabPaneId = tabPane.attr( "id" );
    var tabButton = $( ".nav-link[href=\"#" + tabPaneId + "\"]" );

    tabButton.css( { "font-weight": "bold", "border-top": "3px solid #dc3545" } );
}

$.validator.setDefaults( {

    invalidHandler: function( event, validator ) {

        // NOTE: We use inline styles because I can't override them with a dedicated class.
        $( ".nav-link" ).css( { "font-weight": "normal", "border-top": "" } );

        $.each( validator.errorList, function( i, error ) {
            highlightTabWithError( error.element.name );
        } );

        var count = validator.numberOfInvalids();
        var thisForm = $( event.currentTarget );

        if ( count == 1 ) {
            var message = "<span class='error'>C'è un errore.</span>";
        } else {
            var message = "<span class='error'>Ci sono " + count + " errori.</span>";
        }

        var status = thisForm.find( ".errors-counter" );

        if( status.length == 0 ) {
            var status = $( ".errors-counter" );
        }

        status.html( message );

    },

    showErrors: function( errorMap, errorList ) {

        var thisForm = $( this.currentForm );

        var errors = this.numberOfInvalids();

        var message = "";

        if ( errors == 0 ) {
            $( ".nav-link" ).css( { "font-weight": "normal", "border-top": "" } );
        }

        if ( errors == 1 ) {
            message = "C'è un errore.";
        } else if ( errors > 1 ) {
            message = "Ci sono " + errors + " errori.";
        }

        var status = thisForm.find( ".errors-counter" );

        // se dentro non c'è il loading
        if ( status.length && !status.html().trim().startsWith( "<img" ) ) {
            status.html( message );
        }

        this.defaultShowErrors();

    },
    errorPlacement: function( error, element ) {

        // var thisForm = $( this.currentForm );

        var name = element[ 0 ].name;
        var ele = $( element[ 0 ] );
        var errorEleId = $( "#" + name + "-error" );

        // console.log("errorValidation", name, error);

        // TODO: l'elemento di status dovrebbe essere ricercato nel form
        // in moodo da poter usare lo stesso nome ($elemento-error) più volte nella stessa pagina
        // altrimenti così non si possono avere campi con lo stesso nella stessa pagina.
        // oppure anzichè il $name-error $id-error
        // var eleInForm = thisForm.find( errorEleId );

        if ( !name.length || !errorEleId.length ) {

            var next = ele.next();

            if ( next.hasClass( "input-group-text" ) ) {

                // qui bisognerebbe cercare se si è dentro un "div.input-group"
                next.insertAfter( error );

            } else {

                error.insertAfter( element );

            };

        } else {

            errorEleId.html( error );

        }

    },
    ignore: [ ".ignore" ]
} );


$( document ).ready( function() {

    $( "input[type=text].uppercase" ).keyup( function(){
        this.value = this.value.toUpperCase();
    } );

    $( "#sidebar-button" ).click( function() {
        localStorage.setItem(
            "sidebar-left-collapsed",
            $( "html" ).hasClass( "sidebar-left-collapsed" )
        );
    } );

    $.validator.addMethod( "checkCode", function( value, element ) {
        var re = new RegExp( /^([a-zA-Z0-9_-]+)$/ );
        return this.optional( element ) || re.test( value );
    }, "Please check your input." );

    $.validator.addMethod( "pwdRule", function( value, element ) {
        var re = new RegExp( "(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!_@$%^&*-]).{8,}$", "i" );
        return this.optional( element ) || re.test( value );
    }, "Deve contenere almeno un carattere maiuscolo, un numero e un carattere speciale." );

    $.validator.addMethod( "notEqualTo", function( value, element, param ) {
        return this.optional( element ) || value != $( param ).val();
    }, "This two elements are the same, please change it." );

    setSidebarHeight();

} );

window.addEventListener( "resize", function( event ){
    setSidebarHeight();
} );
