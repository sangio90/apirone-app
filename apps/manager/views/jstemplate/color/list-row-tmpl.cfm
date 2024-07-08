<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="color-list-row-tmpl">
        <tr>
            <td><span data-bind="text: id"></span></td>
            <td><span data-bind="text: name"></span></td>
            <td width="20">
                <input type="checkbox" class="form-check-input" data-bind="click:useColor">
            </td>
        </tr>
    </nmscript>
</cfoutput>