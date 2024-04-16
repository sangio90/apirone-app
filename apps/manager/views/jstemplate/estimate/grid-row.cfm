<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="estimate-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text:shortId"></span>
            </td>
            <td>
                <span data-bind="text:status.name"></span>
            </td>
            <td>
                <span>##=FW.kendo.formatDate(created)##</span>
            </td>
            <td>
                <span data-bind="text:area.name"></span>
            </td>
            <td>
                <span data-bind="text:account.email"></span>
            </td>
            <td>
                <span data-bind="text:type.name"></span>
            </td>
            <td>
                <span data-bind="text:service.name"></span>
            </td>
            <td>
                <span data-bind="text:amount" data-format="c2"></span>
            </td>
            <td>
                <div>
                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:view">
                        <i class="fa-solid fa-eye"></i>
                    </button>
                </div>
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input"
                    name="selected"
                    data-bind="value:id" 
                >
            </td>
        </tr>
    </nmscript>
</cfoutput>
