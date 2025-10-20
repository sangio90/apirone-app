<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="font-family-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td class="text-center">
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: code"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td class="text-center">
                #iconButton(bind="click:edit", icon="edit")#
                #iconButton(bind="click:editPictograms", icon="image")#
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

