<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="property-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: id"></span>
            </td=>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td>
                <a data-bind="click:showValues">Valori</a>
            </td=>
            <td>
                <a data-bind="click:showValues">Elimina</a>
            </td>
        </tr>
    </nmscript>
</cfoutput>