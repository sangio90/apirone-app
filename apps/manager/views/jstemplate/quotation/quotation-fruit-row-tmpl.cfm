<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="quotation-fruit-row-tmpl">
        <div class="quotation-fruit-row" data-fruit-id="##: id ##">
            
            <div class="quotation-fruit-row-header d-flex align-items-center justify-content-between mb-2">
                <div data-bind="text:name" class="quotation-fruit-row-name"></div>
                <div data-bind="click:removeFruit" class="quotation-fruit-row-remove flex-shrink-1">
                    #iconButton(icon="trash")#
                </div>
            </div>

            <div id="quotation-fruit-row-items_##: id ##">
            </div>
            
        </div>
    </nmscript>
</cfoutput>