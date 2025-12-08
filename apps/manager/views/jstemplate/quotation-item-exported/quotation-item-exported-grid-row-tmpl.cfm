<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="quotation-item-exported-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##" style="font-size: 11px">
            <td>
                <span class="key" data-bind="text: key"></span>
            </td>
            <td>
                <span data-bind="text: status"></span>
            </td>
            <td>
                <span class="code" data-bind="text: code"></span>
            </td>
            <td>
                <span class="description" data-bind="text: description"></span>
            </td>
            <td>
                <span data-bind="text: getDate"></span>
            </td>
            <td>
                <span data-bind="text: variant"></span>
            </td>
            <td>
                <span data-bind="text: color"></span>
            </td>
            <td>
                <span data-bind="text: notes"></span>
            </td>
            <td class="text-center">
                #iconButton(bind="click:edit", class="btn-primary", icon="list")#
                #iconButton(bind="click:delete", class="btn-danger", icon="trash")#
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input"
                    name="selected"
                    value="##: key ##"
                >
            </td>
        </tr>
    </nmscript>
</cfoutput>