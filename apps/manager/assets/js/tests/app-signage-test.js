$(document).ready(function(){

    console.log("test:app-signage-attributes")

    
    setTimeout( function() {
        $("body").find("button[data-bind='click:addSignage']").click();
        console.log("test:load");
        
    }, 1000 )

})

