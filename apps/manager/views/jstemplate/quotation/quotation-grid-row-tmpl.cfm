<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="quotation-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
             <td style="border-left: 4px solid ##=statusHistory.status.color.hex##">
                <span data-bind="text: shortId"></span>
            </td>
            <td>
                <span data-bind="text: quotationNumber"></span>/<span data-bind="text: versionNumber"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td>
                <span data-bind="text: referentName"></span>
            </td>
            <td>
                <span data-bind="text: owner.name"></span>
            </td>
            <td>
                <span data-bind="text: getCreatedAt"></span>
            </td>
            <td>
                <span data-bind="text: statusHistory.status.name"></span>
            </td>
            <td class="text-center">
                #iconButton(bind="click:edit", icon="edit")#
                #iconButton(bind="click:destroy", icon="trash")#
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