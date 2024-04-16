<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="account-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: email"></span>
            </td>
            <td>
                <select type="text" class="form-control col-8"
                    data-bind="value: role.id, source: roles" 
                    data-value-field="id"
                    data-text-field="name"
                >
                </select>
            </td>
            <td>
                <select type="text" class="form-control col-8"
                    data-bind="value: status.id, source: statusList" 
                    data-value-field="id"
                    data-text-field="name"
                >
                </select>
            </td>
            <td>
                <span data-bind="text: created"></span>
            </td>
            <td>
                <div>
                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:edit">
                        <i class="fa-solid fa-pen-to-square"></i>
                    </button>
                </div>
            </td>

            <td>
                <div>
                    <input type="checkbox" class="form-check-input"
                        name="selected"
                        data-bind="value:id" 
                    >
                </div>
            </td>
        </tr>
    </nmscript>
</cfoutput>