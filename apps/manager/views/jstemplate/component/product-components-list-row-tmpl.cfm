<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="product-components-list-row-tmpl">
        <tr>
            <td><span data-bind="text: id"></span></td>
            <td><span data-bind="text: name"></span></td>
            <td width="80">
                <span data-bind="visible: showColorsForCount">
                    <input type="button" value="Colori &raquo;" class="btn btn-primary" data-bind="click:showColors">
                </span>
            </td>
            <td width="80">
                <span data-bind="visible: showVariantsForCount">
                    <input type="button" value="Varianti &raquo;" class="btn btn-primary" data-bind="click:showVariants">
                </span>
            </td>
            <td width="80">
                <input type="button" value="Seleziona &raquo;" class="btn btn-primary" data-bind="click:useComponent">
            </td>
        </tr>
    </nmscript>
</cfoutput>