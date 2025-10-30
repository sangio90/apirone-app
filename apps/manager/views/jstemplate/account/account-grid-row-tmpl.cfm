<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="account-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: shortId"></span>
            </td>
            <td>
                <span data-bind="text: email"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td>
                <div data-bind="source: roles" data-template="role-row-tmpl"></div>
            </td>
            <td>
                <span data-bind="text: lang.name"></span>
            </td>
            <td>
                <span data-bind="text: getCreatedAt"></span>
            </td>
            <td>
                <button type="button" class="btn btn-default btn-sm" data-bind="click:edit">
                    <i class="fas fa-edit"></i>
                </button>
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input"
                    name="selected"
                    value="##: id ##"
                >
            </td>
        </tr>
    </nmscript>

    #template( view="jstemplate/role/role-row-tmpl" )#

</cfoutput>




