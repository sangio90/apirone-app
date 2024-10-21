$(document).ready(function(){

    console.log("test:app-line-attributes")

    $("body").find("button[data-bind='click:showAttributesList']").click();

    return;
    
    setTimeout( function() {
        
        $("body").find('button[data-bind="click:addAttribute"]').click();

    }, 1000 )

})

