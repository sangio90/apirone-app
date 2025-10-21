<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="country-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: shortId"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td>
                <span data-bind="text: code"></span>
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

