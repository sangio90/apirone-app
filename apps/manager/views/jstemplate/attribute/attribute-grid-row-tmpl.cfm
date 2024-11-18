<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="attribute-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td>
                <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:showValues">Valori</button>
            </td>
            <td>
                <button type="button" class="btn btn-default btn-sm me-2" data-bind="click:showValues">Rimuovi</button>
            </td>
        </tr>
    </nmscript>
</cfoutput>