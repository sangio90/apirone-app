<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="shipment-total-option-row-tmpl">
        <tr data-uid="##: uid ##" data-bind="visible: showOptionInTotals">
            <td align="right">
                <span data-bind="text:name"></span>
            </td>
            <td align="right">
                <span data-bind="text:amount" data-format="c2"></span> 
            </td>
    </nmscript>
</cfoutput>