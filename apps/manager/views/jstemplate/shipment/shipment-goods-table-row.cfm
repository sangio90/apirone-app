<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="shipment-goods-table-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td class="p-2">
                <span data-bind="text: name"></span>
            </td>
            <td class="p-2">
                <span data-bind="text: year"></span>
            </td>
            <td class="p-2">
                <span data-bind="text: alcoholType.name"></span>
            </td>
            <td class="p-2">
                <span data-bind="text: strength, visible: isAlcoholic"> % vol.</span>
            </td>
            <td class="p-2">
                <span data-bind="text: capacity.value"></span> L
            </td>
            <td class="p-2">
                <span data-bind="text: quantity"></span>
            </td>
            <td class="p-2" align="right">
                <span data-format="c2" data-bind="text: value"></span>
            </td>
            <td class="p-2">
                <button type="button" class="btn btn-secondary btn-sm float-end mb-1" data-bind="click: removeItem">
                    <i title="Cancella etichetta" class="fa-solid fa-trash-can"></i>
                </button>
                <button type="button" class="btn btn-primary btn-sm me-2 float-end mb-1" data-bind="click: editItem">
                    <i title="Modifica etichetta" class="fa-solid fa-pen"></i>
                </button>
            </td>
        </tr>
    </nmscript>
</cfoutput>
