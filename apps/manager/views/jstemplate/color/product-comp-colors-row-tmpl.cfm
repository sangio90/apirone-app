<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="product-comp-colors-row-tmpl">
        <tr>
            <td>
                <b data-bind="text: id"></b><br>
                <span data-bind="text: name"></span>
            </td>
            <td width="80">
                <input type="button" value="Seleziona &raquo;" class="btn btn-primary btn-sm" data-bind="click:useComponent">
            </td>
        </tr>
    </nmscript>
</cfoutput>