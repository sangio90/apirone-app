$(document).ready(function(){

    console.log("test:app-line-attributes")

    $("body").find("button[data-bind='click:showAttributesList']").click();

    setTimeout( function() {

        console.log("test:load");
        
        //$("body").find("button[data-bind='click:openAttributeValues']").eq(1).click();

    }, 1000 )

})

