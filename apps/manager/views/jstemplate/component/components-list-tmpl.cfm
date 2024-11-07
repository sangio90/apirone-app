<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="components-list-tmpl">
        <tr>
            <td>
                <b data-bind="text: id"></b><br>
                <span data-bind="text: name"></span>
            </td>
            <td width="80">
                <span>
                    <input type="button" value="Aggiungi +" class="btn btn-primary btn-sm" data-bind="click:addComponent">
                </span>
            </td>
        </tr>
    </nmscript>
</cfoutput>