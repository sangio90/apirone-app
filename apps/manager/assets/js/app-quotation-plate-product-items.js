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
        // var skipAutoTrigger = opts.skipAutoTrigger === true;
        // fissato skipautotrigger a false perche non vengono caricate le immagini con l'immagine degli items (legno standard su placca wood)
        var skipAutoTrigger = false;

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

            var selectedOption = values.find( function( attrValue ) { return attrValue.selected == true; } );
            if ( selectedOption ) {
                select.val( selectedOption.productItemId );
            } else {
                // Trigger automatico solo per attributi root (level 0) e solo se non siamo in modalità "skipAutoTrigger".
                // skipAutoTrigger viene usato quando renderizziamo dopo loadProductItems per evitare loop infiniti.
                if ( !skipAutoTrigger && item.level === 0 && !item.parentItemId ) {
                    select.prop( "selectedIndex", 0 ).trigger( "change" );
                } else {
                    select.prop( "selectedIndex", 0 );
                }
            }
            subContainer.append( select );
            if (selectedOption && selectedOption.attributeValue.allowNote) {
                //recuperiamo i qipi dalla prima lettura dal backend
                const plateQuotationItemProductItems = AP.plate.modal.getItem().plateQuotationItemProductItems
                let note = ''
                if (plateQuotationItemProductItems.length > 0) {
                    //cerchiamo il qipi che corrisponde al pi selezionato cercando per pi_id e attribute_value_id
                    const selectedPlateOptionQuotationItemProductItem = plateQuotationItemProductItems.find(qipi => 
                        qipi.productItem.attributeValue.id == selectedOption.attributeValue.id &&
                        qipi.productItem.id == selectedOption.productItemId
                    )
                    //se lo troviamo, settiamo le note
                    if (selectedPlateOptionQuotationItemProductItem) {
                        note = selectedPlateOptionQuotationItemProductItem.note
                    }
                }

                //visto che questa procedura gira anche per gli items dei fruits, cerco anche nella struttura dati 
                //quotationItemProductItems dei frutti. Se ne trovo:
                const fruitQuotationItemProductItems = AP.plate.modal.getItem().fruitQuotationItemProductItems
                if (fruitQuotationItemProductItems.length > 0) {
                    //cerchiamo il qipi che corrisponde al pi selezionato cercando per fruit_id (preso dal id container jquery), pi_id e attribute_value_id
                    //non bastano pi_id e av_id perche potremmo avere due frutti uguali con note diverse
                    const selectedFruitOptionQuotationItemProductItem = fruitQuotationItemProductItems.find( qipi =>
                        qipi.product_item_id == selectedOption.productItemId &&
                        qipi.attribute_value_id == selectedOption.attributeValue.id &&
                        qipi.quotation_item_fruit_id == container[0].id.split("_").pop()
                    ) 
                    //se lo troviamo, settiamo le note
                    if (selectedFruitOptionQuotationItemProductItem) {
                        note = selectedFruitOptionQuotationItemProductItem.note
                    }
                }

                const labelNote = $( "<label>" );
                labelNote.addClass( "mb-1" );
                labelNote.css( "margin-left", ( 1.5 * item.level ) + "rem" );
                labelNote.text( "NOTE" );
                subContainer.append( labelNote );
                if ("note" in selectedOption) {
                    note = selectedOption.note
                } else {
                    selectedOption.note = ''
                }
                //definisco il tag html e imposto onchange una funzione che cerca in product items notes dentro il viewmodel se trova un elemento per product item id e attribute value id
                const inputNote = $( "<input>" ).addClass( "form-control me-3 mb-2" )
                .on("input", function () {
                    note = this.value
                    selectedOption.note = note
                });
                inputNote.attr( "data-attribute-id", item.attribute_id );
                inputNote.val(note)
                if ( item.level > 0 ) {
                    inputNote.css( "margin-left", ( 1.5 * item.level ) + "rem" );
                    inputNote.css( "width", `calc(100% - ${1.5 * item.level}rem)` );
                }
                subContainer.append( inputNote );
            }
        } );
    }

    return {
        renderProductItems: renderProductItems
    };

}() );
