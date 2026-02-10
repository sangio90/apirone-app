/**
 * Modulo API per la modale placca: centralizza URL e chiamate NM.util.ajax.
 * Ogni metodo accetta un callback { done: function(xhr) } e restituisce il valore di NM.util.ajax (per .then() dove serve).
 * Dipende da: NM (globale), jQuery.
 */
AP.namespace( "plate.api" );

AP.plate.api = ( function() {

    var BASE = "/manager/ajax";

    function ajax( opts ) {
        return NM.util.ajax( opts );
    }

    function getFrameForOrientation( frameId, orientationId, productId, callback ) {
        var url = BASE + "/frames/" + frameId + "?orientationId=" + orientationId + "&productId=" + productId;
        return ajax( { method: "GET", url: url, callback: callback } );
    }

    function getFrame( frameId, callback ) {
        var url = BASE + "/frames/" + frameId;
        return ajax( { method: "GET", url: url, callback: callback } );
    }

    function getProductItems( productId, originId, callback ) {
        var url = BASE + "/product-items?productId=" + productId;
        if ( originId ) {
            url += "&originId=" + originId;
        }
        return ajax( { method: "GET", url: url, callback: callback } );
    }

    function getQuotationItemProductItems( quotationItemId, callback ) {
        var url = BASE + "/quotation-items/" + quotationItemId + "/product-items";
        return ajax( { method: "GET", url: url, callback: callback } );
    }

    function getQuotationItemFruitProductItems( quotationItemFruitId, callback ) {
        var url = BASE + "/quotation-items/fruits/" + quotationItemFruitId + "/product-items";
        return ajax( { method: "GET", url: url, callback: callback } );
    }

    function getProductByParams( categoryId, lineId, modelId, finishId, callback ) {
        var url = BASE + "/quotation-items/product/by-params" +
            "?categoryId=" + categoryId +
            "&lineId=" + lineId +
            "&modelId=" + modelId +
            "&finishId=" + finishId;
        return ajax( { method: "GET", url: url, callback: callback } );
    }

    function getLines( categoryId, callback ) {
        var url = BASE + "/quotations/lines/" + ( categoryId || "22" );
        return ajax( { method: "GET", url: url, callback: callback } );
    }

    function getModels( lineId, callback ) {
        var url = BASE + "/quotations/models/" + lineId;
        return ajax( { method: "GET", url: url, callback: callback } );
    }

    function getFinishes( categoryId, lineId, callback ) {
        var url = BASE + "/quotations/finishes/" + ( categoryId || "22" ) + "/" + lineId;
        return ajax( { method: "GET", url: url, callback: callback } );
    }

    function savePlate( payload, callback ) {
        var url = BASE + "/quotation-items/plate";
        return ajax( {
            method: "POST",
            url: url,
            data: JSON.stringify( payload ),
            callback: callback
        } );
    }

    function getPlate( id, callback ) {
        var url = BASE + "/quotation-items/plate/" + id;
        return ajax( { method: "GET", url: url, callback: callback } );
    }

    function getPlateFruits( id, callback ) {
        var url = BASE + "/quotation-items/plate/" + id + "/fruits";
        return ajax( { method: "GET", url: url, callback: callback } );
    }

    return {
        getFrameForOrientation: getFrameForOrientation,
        getFrame: getFrame,
        getProductItems: getProductItems,
        getQuotationItemProductItems: getQuotationItemProductItems,
        getQuotationItemFruitProductItems: getQuotationItemFruitProductItems,
        getProductByParams: getProductByParams,
        getLines: getLines,
        getModels: getModels,
        getFinishes: getFinishes,
        savePlate: savePlate,
        getPlate: getPlate,
        getPlateFruits: getPlateFruits
    };

}() );
