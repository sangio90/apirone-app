<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="permissions-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
             <td>
                <span data-bind="text: permission.id"></span>
            </td>
            <td>
                <span data-bind="text: permission.name"></span>
            </td>
            <td>
                <span data-bind="text: getCreatedAt"></span>
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input"
                    data-bind="checked: active"
                    name="selected"
                    value="##: id ##"
                >
            </td>
        </tr>
    </nmscript>
</cfoutput>