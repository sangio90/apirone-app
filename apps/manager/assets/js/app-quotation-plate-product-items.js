/**
 * Modulo rendering product items (attributi) per placca e frutti.
 * Usato da AP.plate.modal per select placca e select frutti.
 * Dipende solo da jQuery.
 */
AP.namespace( "plate.productItems" );

AP.plate.productItems = ( function() {

    /**
     * Renderizza i select degli attributi (product items) in un container.
     * @param {Object} opts
     * @param {string} opts.containerSelector - selector jQuery del container (es. "#quotation-plate-product-items")
     * @param {Array} opts.attributeArray - array da productItems.data() o fruit.get("items").data()
     * @param {string} opts.subContainerIdPrefix - prefisso id per ogni blocco (es. "attribute-container-" o "fruit-attribute-container-")
     * @param {function(Object):string} opts.labelTextFn - (item) => testo della label
     * @param {function(string, string, *)} opts.onSelectChange - (selectedId, attributeId, value) chiamato al change
     */
    function renderProductItems( opts ) {
        var container = $( opts.containerSelector );
        container.empty();

        var attributeArray = opts.attributeArray;
        var subContainerIdPrefix = opts.subContainerIdPrefix;
        var labelTextFn = opts.labelTextFn;
        var onSelectChange = opts.onSelectChange;

        attributeArray.forEach( function( item ) {
            var newLevel = ( 1.5 * item.level ) + "rem";
            var values = item.values;

            var subContainer = $( "<div>" );
            subContainer.attr( "id", subContainerIdPrefix + item.attributeId );
            container.append( subContainer );

            var label = $( "<label>" ).addClass( "mb-1" ).css( "margin-left", newLevel ).text( labelTextFn( item ) );
            subContainer.append( label );

            var select = $( "<select>" )
                .addClass( "form-control form-control-sm select-item me-3 mb-2" )
                .on( "change", function() {
                    var selectedId = $( this ).val();
                    var attributeId = $( this ).data( "attribute-id" );
                    var value;
                    for ( var i = 0; i < item.values.length; i++ ) {
                        if ( item.values[i].productItemId == selectedId ) {
                            value = item.values[i];
                            break;
                        }
                    }
                    onSelectChange( selectedId, attributeId, value );
                } );
            select.attr( "data-attribute-id", item.attributeId );

            if ( item.level > 0 ) {
                select.css( "margin-left", newLevel );
                select.css( "width", "calc(100% - " + ( 1.5 * item.level ) + "rem)" );
            }

            values.forEach( function( attrValue ) {
                var option = $( "<option>" )
                    .val( attrValue.productItemId )
                    .html( attrValue.attributeValue.rawValue.name );
                select.append( option );
            } );

            var selectedOption = values.find( function( attrValue ) { return attrValue.selected === true; } );
            if ( selectedOption ) {
                select.val( selectedOption.productItemId );
            } else {
                select.prop( "selectedIndex", 0 ).trigger( "change" );
            }
            subContainer.append( select );
        } );
    }

    return {
        renderProductItems: renderProductItems
    };

}() );
