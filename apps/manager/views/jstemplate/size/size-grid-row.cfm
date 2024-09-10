<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="size-grid-row">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td>
                <div>
                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:edit">
                        <i class="fas fa-edit"></i>
                    </button>
                </div>
            </td>
            <td>
                <div>
                    <input type="checkbox" class="form-check-input" name="selected"
                        data-bind="value:id" 
                    >
                </div>
            </td>
        </tr>
    </nmscript>
</cfoutput>