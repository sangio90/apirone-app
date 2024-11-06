<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="text-grid-row">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td>
                <span data-bind="text: lang.name"></span>
            </td>
            <td class="text-center">
                <button type="button" class="btn btn-primary btn-sm" data-bind="click:edit">
                    <i class="fas fa-edit"></i>
                </button>
            </td>
            <td align="center">
                <input type="checkbox" class="form-check-input"
                    name="selected"
                    data-bind="value:id" 
                >
            </td>
        </tr>
    </nmscript>
</cfoutput>