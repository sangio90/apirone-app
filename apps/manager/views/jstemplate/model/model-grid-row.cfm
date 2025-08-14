<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="model-grid-row">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: shortId"></span>
            </td>
            <td>
                <span data-bind="text: code"></span>
            </td>
            <td class="text-center">
                <span data-bind="text: type.id"></span>
            </td>
            <td>
                <span data-bind="text: nameItem.name"></span>
            </td>
            <td>
                <div data-bind="source: categories" data-template="product-category-row-tmpl"></div>
            </td>
            <td class="text-end">
                <span data-bind="text: fruitsCount"></span>
            </td>
            <td>
                #iconButton(bind="click:edit", icon="edit")#
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input" name="selected"
                    value="##: id ##"
                >
            </td>
        </tr>
    </nmscript>

    #template( view="jstemplate/product-category/product-category-row-tmpl" )#

</cfoutput>