<cfscript>
    function combinationExists( sizeId, finishId ){ 

        var result = ArrayContains( prc.existingCombinations, "#sizeId#__#finishId#") > 0 ? true : false;

        return result;
    }
</cfscript>
