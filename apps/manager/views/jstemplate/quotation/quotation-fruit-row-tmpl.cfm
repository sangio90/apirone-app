<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="quotation-fruit-row-tmpl">
        <div class="quotation-fruit-row" data-fruit-id="##: id ##">
            
            <div class="quotation-fruit-row-header d-flex align-items-center justify-content-between mb-2" data-bind="click:toggleFruit" style="cursor: pointer;">
                <div class="quotation-fruit-row-name">
                    <b data-bind="text:fruit.name"></b>
                    <span class="small-code">(<span data-bind="text: fruit.code"></span>)</span>
                </div>
                <div data-bind="click:removeFruit" class="quotation-fruit-row-remove flex-shrink-1" style="cursor: pointer;">
                    #iconButton(icon="trash")#
                </div>
            </div>

            <div id="quotation-fruit-row-items_##: id ##" data-bind="visible:expanded">
            </div>
            
        </div>
    </nmscript>
</cfoutput>