<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="value-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td width="50">
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
        </tr>
    </nmscript>
</cfoutput>