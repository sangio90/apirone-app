<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="product-combinations-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: shortId"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td class="text-center">
                #iconButton(bind="click:image", icon="external-link-square-alt")#
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