<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="attribute-lang-row-tmpl">
        <div class="mb-3 row">
            
            <label class="col-sm-2 col-form-label text-end" 
                for="lang_##=lang.id##" 
                data-bind="text:lang.name">
            </label>
            
            <div class="col-sm-10">
                <input type="text" required class="lang form-control" 
                    id="lang_##=lang.id##" 
                    name="lang_##=lang.id##"
                    data-msg-required="Campo richiesto">
            </div>
        
        </div>
    </nmscript>
</cfoutput>