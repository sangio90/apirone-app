AP.namespace( "search" );

Object.assign( AP.search.fields, {
    widgetRoot: $( "#search-widget-root" ),
    widgetInput: $( "#search-widget-suggest-input" ),
    widgetStatus: $( "#search-widget-suggest-status" ),
} );

$( document ).ready( function(){

    if ( AP.search.fields.widgetRoot.length ) {
        AP.search.widget.init();
    }

} );

AP.search.widget = ( function() {

    var pub = {};

    var fields = AP.search.fields;

    var initSuggest = function() {

        var suggest = fields.widgetInput;
        var autocomplete = suggest.data( "kendoAutoComplete" );
        var suggestTemplate = $( "#search-widget-suggest-row-tmpl" ).html();

        if ( autocomplete ) {
            return;
        }

        suggest.keypress( function( event ) {
            if( event.keyCode == 13 ){
                return false;
            }
        } );

        suggest.kendoAutoComplete( {
            template: $.proxy( kendo.template( suggestTemplate ) ),
            // template: $.proxy( kendo.template( "#= formatValue(data, this.val()) #" ), suggest ),
            dataTextField: "term",
            highlightFirst: true,
            minLength: 4,
            dataSource: new kendo.data.DataSource( {
                serverFiltering: true,
                transport: {
                    read: {
                        url: "/manager/ajax/search",
                        data: {
                            str: function() {
                                return suggest.data( "kendoAutoComplete" ).value();
                            },
                        },
                    },
                    parameterMap : function( data, type ) {
                        if ( type === "read" ) {
                            return { "str": data.str() };
                        }
                    }
                },
                schema: {
                    data: function( xhr ) {
                        return xhr.data;
                    }
                },
            } ),
            select: function( event ) {
                var dataItem = this.dataItem( event.item.index() );

                fields.widgetStatus.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

                window.location.href = "/manager/products/" + dataItem.productId + "/detail";
            },
            noDataTemplate: "<div>NESSUN RECORD</div>"
        } );

    };

    pub.init = function() {

        fields.widgetRoot.removeClass( "d-none" );

        initSuggest();

        document.onkeydown = function( event ) {
            // prefer ev.key (carattere) e ev.code (tasto fisico). fallback a keyCode se serve ancora supporto legacy
            var key = event.key || event.code || event.keyCode;
            var isK = ( key === "k" || key === "K" || key === "KeyK" || key === 75 );

            if ( event.ctrlKey && isK ) {
                event.preventDefault();
                event.stopPropagation();
                fields.widgetInput.focus();
                return false;
            }
        };

    };

    return pub;

}() );
