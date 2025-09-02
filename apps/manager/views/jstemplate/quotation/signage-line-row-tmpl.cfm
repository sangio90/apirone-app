<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="signage-line-row-tmpl">
        <div class="border rounded p-3 mb-3">
            <div class="mb-3 row">
                <div class="col-9" data-bind="text:id"></div>
                <div class="col-3">
                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:updateLine">Aggiorna</button>
                </div>
            </div>
            <div class="mb-3 row">
                <div class="col-12"></div>
            </div>
        </div>
    </nmscript>
</cfoutput>