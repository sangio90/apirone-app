<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="catalog-bundle-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: shortId"></span>
            </td>
            <td>
                <span data-bind="text: getCreatedAt"></span>
            </td>
            <td>
                <span data-bind="text: category.name"></span>
                <span class="small-code">(<span data-bind="text: category.code"></span>)</span>
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
                <input type="text" class="form-control input-sm" data-bind="value: markupValue" />
            </td>
        </tr>
    </nmscript>
</cfoutput>