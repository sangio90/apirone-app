<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="quotation-exported-rows-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##" style="font-size: 11px">
            <td style="text-align: center">
                <span class="rowNumber" data-bind="text: rowNumber"></span>
            </td>
            <td>
                <span data-bind="text: productCode"></span>
            </td>
            <td>
                <span data-bind="text: variantCode"></span>
            </td>
            <td>
                <span data-bind="text: colorCode"></span>
            </td>
            <td>
                <span data-bind="text: um"></span>
            </td>
            <td style="text-align: right">
                <span data-bind="text: quantity"></span>
            </td>
            <td>
                <span data-bind="text: price"></span>
            </td>
            <td>
                <span data-bind="text: discoun1"></span>
            </td>
            <td>
                <span data-bind="text: discount2"></span>
            </td>
            <td class="text-center">
                #iconButton(bind="click:delete", class="btn-danger", icon="trash")#
            </td>
        </tr>
    </nmscript>
</cfoutput>