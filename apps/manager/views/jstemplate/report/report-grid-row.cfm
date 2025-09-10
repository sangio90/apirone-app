<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="report-grid-row">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: shortId"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td>
                <span data-bind="text: fileName"></span>
            </td>
            <td nowrap>
                <span data-bind="text: exampleFile"></span>
            </td>
            <td>
                <div>
                    <button type="button" class="btn btn-default btn-sm" data-bind="click:edit">
                        <i class="fas fa-edit"></i>
                    </button>
                </div>
            </td>
            <td>
                <div>
                    <input type="checkbox" class="form-check-input"
                        name="selected"
                        value="##: id ##"
                    >
                </div>
            </td>
        </tr>
    </nmscript>
</cfoutput>