<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="product-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: shortId"></span>
            </td>
            <td>
                <span data-bind="text: category.name"></span>
            </td>
            <td>
                <span data-bind="text: line.name"></span>
                <span class="small-code">(<span data-bind="text: line.code"></span>)</span>
            </td>
            <td>
                <span data-bind="text: model.name"></span>
                <span class="small-code">(<span data-bind="text: model.code"></span>)</span>
            </td>
            <td>
                <span data-bind="text: finish.name"></span>
            </td>
            <td class="text-center">
                #iconButton(bind="click:attributes", icon="external-link-square-alt")#
            </td>
        </tr>
    </nmscript>
</cfoutput>