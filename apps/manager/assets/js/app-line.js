AP.line = AP.line || {};

AP.line.fields = {
    listRoot: $('#line-list-root'),
    searchListForm: $('#line-grid-search-form'),
    combinationsRoot: $('#line-combinations-root')
}

$(document).ready(function(){

	if ( AP.line.fields.listRoot.length ) {

	    AP.line.list.init();

	}

	if ( AP.line.fields.combinationsRoot.length ) {

	    AP.line.combinations.init();

	}

})

AP.line.list = function() {

	var pub = {}

	var dataSources = {
		items: NM.kendo.dataSource( { url: "/manager/ajax/lines" } )
	}

	var viewModel = kendo.observable({
		rows: dataSources.items,
        
        search: function( event ) {

            var thisForm = AP.line.fields.searchListForm;

            var params = thisForm.serializeJSON();

            console.log( "search", event );
            console.log( "params", params );

            //$('form').serializeJSON();

            viewModel.rows.read( params )

            return false;

        },

        open: function( event ) {

            var id = event.data.id
            window.open( "/manager/lines/" + id, '_blank').focus();

        },

		print: function( item ) {

            window.open('/manager/lines/print', '_blank');

            return false;
		},

		combinations: function( event ) {

            var id = event.data.id
            window.open( "/manager/lines/" + id + "/combinations", '_blank').focus();

            return false;
		},


		attributes: function( event ) {

            /*
                note: redirect in controller to first combination
            */

            var id = event.data.id
            window.open( "/manager/lines/" + id + "/attributes", '_blank').focus();

            return false;
		},


	});

	pub.init = function() {

        console.log("init")

        kendo.bind( AP.line.fields.listRoot, viewModel );

	}	

    return pub;
}();



AP.line.combinations = function() {

    var pub = {};


    var changeStatus = function( status, event ) {

        //active 
        var method = "POST";
        var classToShow = "active";
        var classToHide = "deactive";
        var message = "Combinazione salvata";

        //deactive
        if ( status == "deactive" ) {
            method = "DELETE"
            classToShow = "deactive";
            classToHide = "active";
            message = "Combinazione rimossa";
        }

        var status = $("#line-combinations-status");
        var values = $(event.currentTarget).data( "values" );

        status.html('<img src="/assets/main/img/ajax-loading.svg" width="20" height="20">');

        var size = values.split( "__" )[0];
        var finish = values.split( "__" )[1];

        NM.util.ajax({ 
            method: method, 
            url: "/manager/ajax/lines/" + AP.page.line.id + "/combinations",
            data: JSON.stringify( { 
                    sizeId: size,
                    finishId: finish
                } 
            ),
            callback: {
                done: function( xhr ) {

                    if( xhr.status == "SUCCESS" ) {

                        var payload = xhr.data.payload;

                        var button = $("button[data-values='" + values +"']");

                        button.filter( "." + classToShow ).show();
                        button.filter( "." + classToHide ).hide();

                        status.html("<span class='green'>" + message + "</span> ");

                    }

                }
            }
        })
        
        return false;
    
    }

	var viewModel = kendo.observable({

        activate: function( event ) {

            event.preventDefault();

            changeStatus("active", event);

		},

        deactivate: function( event ) {
            
            event.preventDefault();

            //TODO: add confirmation modal

            var isSure = confirm("Sei sicuro di voler cancellare questa combinazione?");

            if ( isSure ) {
                changeStatus("deactive", event);
            }
		
        },


	});    

	pub.init = function() {

		kendo.bind( AP.line.fields.combinationsRoot, viewModel )
        
	}	

    return pub;

}();
