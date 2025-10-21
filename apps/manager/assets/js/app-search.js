AP.namespace( "search" );

Object.assign( AP.search.fields, {
    widgetRoot: $( "#search-widget-root" ),
    widgetInput: $( "#search-widget-suggest-input" ),
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

        suggest.keypress( function( event ){
            if( event.keyCode == 13 ){
                return false;
            }
        } );

        suggest.kendoAutoComplete( {
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

                window.location.href = "/manager/products/" + dataItem.productId + "/detail";

            },
            template: kendo.template( suggestTemplate ),
            noDataTemplate: "<div>NESSUN RECORD</div>"
        } );

    };

    pub.init = function() {

        console.log( "search:init" );

        initSuggest();

    };

    return pub;

}() );
