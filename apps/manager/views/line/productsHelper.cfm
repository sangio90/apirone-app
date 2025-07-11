<cfscript>
    function productExists( sizeId, finishId ){ 

        var result = ArrayContains( prc.existingProducts, "#sizeId#__#finishId#") > 0 ? true : false;

        return result;
    }
</cfscript>
