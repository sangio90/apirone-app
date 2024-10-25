$(document).ready(function(){

    console.log("test:app-line-attributes")

    $("body").find("button[data-bind='click:showAttributesList']").click();

    setTimeout( function() {

        console.log("ciao");
        
        $("body").find("button[data-bind='click:showAttributeValues']").eq(1).click();

    }, 1000 )

})

