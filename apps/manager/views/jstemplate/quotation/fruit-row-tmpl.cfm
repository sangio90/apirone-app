<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="fruit-row-tmpl">
        <div class="quotation-fruit-row" data-fruit-id="##: id ##">
            
            <div data-bind="text:name" class="quotation-fruit-row-name"></div>
            
            <div data-bind="text:name" class="quotation-fruit-row-items">
                
            </div>
        </div>
    </nmscript>
</cfoutput>