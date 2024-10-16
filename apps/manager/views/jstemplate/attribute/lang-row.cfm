<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="attribute-lang-row-tmpl">
        <div class="mb-3 row">
            <label for="lang_##=id##" class="col-sm-2 col-form-label text-end" data-bind="text:name"></label>
            <div class="col-sm-10">
                <input type="text" required class="lang form-control" id="lang_##=id##" name="lang_##=id##">
            </div>
        </div>
    </nmscript>
</cfoutput>