<cfoutput>
    <nmscript type="text/x-kendo-template" id="pallet-pallex-item-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <input name="" data-bind="value: width" class="form-control" placeholder="Larghezza">
            </td>
            <td>
                <input name="" data-bind="value: length" class="form-control" placeholder="Lunghezza">
            </td>
            <td>
                <input name="" data-bind="value: height" class="form-control" placeholder="Altezza">
            </td>
            <td>
                <input name="" data-bind="value: weight" class="form-control" placeholder="Peso">
            </td>
            <td>
                <input name="" data-bind="value: pltNumber" class="form-control" placeholder="Nr. Plt">
            </td>            
            <td>
                <input name="" data-bind="value: epalNumber" class="form-control" placeholder="Nr. Epal a scambio">
            </td>
            <td width="50">
                <i class="fa-solid fa-trash" data-bind="click:deleteFormRow"></i>
            </td>
        </tr>
    </nmscript>
</cfoutput>
