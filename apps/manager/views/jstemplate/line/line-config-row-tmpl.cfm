<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="line-config-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: mainText.name"></span>
            </td>
            <td>
                <span data-bind="text: status.name"></span>
            </td>
            <td class="text-center">
                <button type="button" class="btn btn-primary btn-sm" data-bind="click:addAttribute">
                    <i class="fas fa-plus"></i> 
                </button>
            </td>
            <td class="text-center">
                <button type="button" class="btn btn-primary btn-sm" data-bind="click:removeAttribute">
                    <i class="fas fa-trash"></i> 
                </button>
            </td>
        </tr>
    </nmscript>
</cfoutput>