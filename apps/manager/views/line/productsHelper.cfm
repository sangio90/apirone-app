<cfscript>
    function productExists( modelId, finishId ){ 

        var result = ArrayContains( prc.existingProducts, "#modelId#__#finishId#") > 0 ? true : false;

        return result;
    }
</cfscript>
