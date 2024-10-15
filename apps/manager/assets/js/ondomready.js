if ( localStorage.getItem("sidebar-left-position") !== null ) {
	var initialPosition = localStorage.getItem("sidebar-left-position");
	var sidebarLeft = document.querySelector("#sidebar-left .nano-content");

	if ( sidebarLeft ) {
		sidebarLeft.scrollTop = initialPosition;
	}
	
}

// the overlay shows above the first modal, not in the back.
// https://stackoverflow.com/questions/19305821/multiple-modals-overlay
$(document).on("show.bs.modal", ".modal", function() {
    const zIndex = 1040 + 10 * $(".modal:visible").length;
	console.log("zIndex", zIndex)
    $(this).css("z-index", zIndex);
    setTimeout(() => $(".modal-backdrop").not(".modal-stack").css("z-index", zIndex - 1).addClass("modal-stack"));
});


if ( localStorage.getItem( "sidebar-left-collapsed" ) == "true" ) {
	
	document.getElementsByTagName( "html" )[0]
		.classList.add("sidebar-left-collapsed")

} else {

	document.getElementsByTagName( "html" )[0]
		.classList.remove("sidebar-left-collapsed")

}

$.validator.setDefaults( {

	invalidHandler: function( event, validator ) {

		console.log("invalidHandler")

		var count = validator.numberOfInvalids();

		console.log("invalidHandler:count", count);

	},
	
	errorPlacement: function( error, element ) {

		//console.log("errorPlacement", error)

		var name = element[ 0 ].name;
		var ele = $( element[ 0 ] );
		var errorEle = $( '#' + name + '-error' );

		console.log("errorEle", errorEle)

		if ( !name.length || !errorEle.length ) {
			
			var next = ele.next();

			if ( next.hasClass('input-group-text') ) {

				//qui bisognerebbe cercare se si è dentro un "div.input-group"
				next.insertAfter( error );

			} else {

				error.insertAfter( element )
			
			};
		
		} else {
			
			errorEle.html( error )

		}

	},
	ignore: [".ignore"]
} );    

$( document ).ready(function() {

	console.log("onDomReady")

	$("#sidebar-button").click(function() {
		localStorage.setItem( 
			"sidebar-left-collapsed", 
			$( "html" ).hasClass( "sidebar-left-collapsed" ) 
		)
	});	

    $.validator.addMethod(
        "checkCode",
        function(value, element) {
          var re = new RegExp( /^([a-zA-Z0-9_-]+)$/ );
          return this.optional(element) || re.test(value);
        },
        "Please check your input."
    );

	//console.log("$.validator", $.validator);

});
