<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="component-grid-row-tmpl">
        <tr>
            <td>
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: rawProduct.name"></span>
                <br>
                <span class="small-code">(<span data-bind="text: rawProduct.id"></span>)</span>
            </td>
            <td>
                <span data-bind="text: variant.name"></span>
                <br>
                <span class="small-code">(<span data-bind="text: variant.id"></span>)</span>
            </td>
            <td>
                <span data-bind="text: color.name"></span>
                <br>
                <span class="small-code">(<span data-bind="text: color.id"></span>)</span>
            </td>
            <td>
                <span data-bind="text: kindId"></span>
            </td>
            <td class="text-end">
                <span data-bind="text: cost.amount"></span>
                <span>€</span>
            </td>
        </tr>
    </nmscript>
</cfoutput>