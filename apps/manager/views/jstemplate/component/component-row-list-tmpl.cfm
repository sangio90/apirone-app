<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="component-row-list-tmpl">
        <tr>
            <td>
                <b data-bind="text: id"></b><br>
                <span data-bind="text: name"></span>
            </td>
            <td width="120">
                <span data-bind="visible: showVariantsForCount">
                    <input type="button" value="Varianti &raquo;" class="btn btn-primary btn-sm" data-bind="click:openVariants">
                </span>
            </td>
            <td width="120">
                <input type="button" value="Seleziona &raquo;" class="btn btn-primary btn-sm" data-bind="click:useComponent">
            </td>
        </tr>
    </nmscript>
</cfoutput>