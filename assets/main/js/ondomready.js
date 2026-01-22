/*
	set position left sidebar
*/

if ( localStorage.getItem( "sidebar-left-position" ) !== null ) {
    var initialPosition = localStorage.getItem( "sidebar-left-position" );
    var sidebarLeft = document.querySelector( "#sidebar-left .nano-content" );

    if ( sidebarLeft ) {
        sidebarLeft.scrollTop = initialPosition;
    }

}


/*
	set collapse left sidebar
*/

if ( localStorage.getItem( "sidebar-left-collapsed" ) == "true" ) {

    document.getElementsByTagName( "html" )[0]
        .classList.add( "sidebar-left-collapsed" );

} else {

    document.getElementsByTagName( "html" )[0]
        .classList.remove( "sidebar-left-collapsed" );

}

$( document ).ready( function(){

    $( "#sidebar-button" ).click( function() {
        localStorage.setItem(
            "sidebar-left-collapsed",
            $( "html" ).hasClass( "sidebar-left-collapsed" )
        );
    } );

    /*
		cards:
		all "dismiss" command in card closes div with id in "data-dismiss"
	*/

    $( ".card-actions .card-action-dismiss" ).click( function( event ) {
        var ele = $( this ).data( "dismiss" );
        $( "#" + ele ).addClass( "d-none" );
    } );


    /*
		validator
	*/

    $.validator.addMethod( "pwdRule", function( value, element ) {
        var re = ZB.config.regexp.pwd;
        return this.optional( element ) || re.test( value );
    }, "At least one char uppercase, one char lowercase, at least one number." );

    $.validator.setDefaults( {

        errorPlacement: function( error, element ) {

            var name = element[ 0 ].name;
            var ele = $( element[ 0 ] );
            var errorEle = $( "#" + name + "-error" );

            if ( !name.length || !errorEle.length ) {

                var next = ele.next();

                if ( next.hasClass( "input-group-text" ) ) {

                    // qui bisognerebbe cercare se si è dentro un "div.input-group"
                    next.insertAfter( error );

                } else {

                    error.insertAfter( element );

                };

            } else {

                errorEle.html( error );

            }

        },
        ignore: [ ".ignore" ]
    } );

} );
