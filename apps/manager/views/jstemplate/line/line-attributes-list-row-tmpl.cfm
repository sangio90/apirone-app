<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="line-attributes-list-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: getAttributeName"></span>
            </td>
            <td>
                <span class="square-color" data-bind="style: { backgroundColor: status.color.hex }">
                    &nbsp;
                </span>
            </td>
            <td>
                <div>
                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:addAttribute">
                        <i class="fas fa-edit"></i>
                    </button>
                </div>
            </td>
        </tr>
    </nmscript>
</cfoutput>