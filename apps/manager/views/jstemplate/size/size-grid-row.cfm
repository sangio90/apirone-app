<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="size-grid-row">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: shortId"></span>
            </td>
            <td>
                <span data-bind="text: code"></span>
            </td>
            <td>
                <span data-bind="text: mainText.name"></span>
            </td>
            <td>
                <div data-bind="source: categories" data-template="category-row-tmpl"></div>
            </td>
            <td>
                <span data-bind="text: fruitsCount"></span>
            </td>
            <td>
                #iconButton(bind="click:edit", icon="edit")#
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input" name="selected"
                    data-bind="value:id" 
                >
            </td>
        </tr>
    </nmscript>

    #template( view="jstemplate/category/category-row-tmpl" )#

</cfoutput>