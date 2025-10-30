<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="signage-line-preview-row-tmpl">
        <div class="k-master-row" data-uid="##: uid ##">
            <div class="p-3" data-bind="style: { textAlign: textAlign }">
                <span id="content_span_preview_##: id ##" data-bind="text: content"></span>
            </div>
        </div>
    </nmscript>
</cfoutput>