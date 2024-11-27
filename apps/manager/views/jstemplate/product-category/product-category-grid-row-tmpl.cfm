<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="product-category-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
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