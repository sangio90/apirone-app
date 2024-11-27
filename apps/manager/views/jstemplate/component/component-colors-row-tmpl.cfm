<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="component-colors-row-tmpl">
        <tr>
            <td>
                <b data-bind="text: id"></b><br>
                <span data-bind="text: name"></span>
            </td>
            <td width="30">
                <input type="button" value="&raquo;" class="btn btn-primary btn-sm" data-bind="click:useColor">
            </td>
        </tr>
    </nmscript>
</cfoutput>