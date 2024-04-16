<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="pricelist-document-type-row-tmpl">

        <div class="form-check">
            <input class="form-check-input" type="checkbox" id="doc_##=id##" data-bind="checked: data.documentTypes, value: id">
            <label class="form-check-label" for="doc_##=id##" data-bind="text: name"></label>
        </div>        

    </nmscript>
</cfoutput>
