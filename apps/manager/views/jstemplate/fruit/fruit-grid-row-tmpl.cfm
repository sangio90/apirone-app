<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="fruit-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: shortId"></span>
            </td>
            <td>
                <span data-bind="text: code"></span>
            </td>
            <td>
                <span data-bind="text: mainText.name"></span>
            </td>
            <td class="text-end">
                <span data-bind="text: positionsCount"></span>
            </td>
            <td class="text-center">
                <button type="button" class="btn btn-default btn-sm" data-bind="click:attributes">
                    <i class="fas fa-window-restore"></i> 
                </button>
            </td>
            <td class="text-center">
                #iconButton(bind="click:edit", icon="edit")#
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input"
                    name="selected"
                    value="##: id ##"
                >
            </td>
        </tr>
    </nmscript>
</cfoutput>