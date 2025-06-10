$(document).ready(function(){

    console.log("test:app-attribute-test");

    var attribute = AP.attribute.detail.init();

    var onCreate = function() {
        console.log("onCreate");
    };

    var callback = {};

    /*
    setTimeout( function() {

        console.log("test:load");

        AP.attribute.detail.new( { onCreate: onCreate } );


    }, 1000 );
    */

    var attributeId = "135c169f-3a8f-4353-b509-838f9799d482"; 

    setTimeout( function() {

        console.log("test:load:edit");

        AP.attribute.detail.edit( { id:  attributeId, onCreate: onCreate } );


    }, 1000 );

});

