<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="quotation-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: billingProfile.name"></span>
            </td>
            <td>
                <span data-bind="text: quotationNumber"></span>/<span data-bind="text: versionNumber"></span>
            </td>
            <td>
                <span data-bind="text: getDate"></span>
            </td>
            <td>
                <span data-bind="text: status.name"></span>
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