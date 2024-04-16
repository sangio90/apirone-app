<cfoutput>
    <nmscript type="text/x-kendo-template" id="shipment-pallets-item-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text:shortId" width="100px"></span>
            </td>
            <td>
                <span data-bind="text:code"></span>
            </td>
            <td>
                <span data-bind="text:getDate"></span>
            </td>
            <td width="50px" align="center">
                <input name="pallet" type="radio" value="##: id ##"
                    data-rule-required="true"
                    data-msg-required="Seleziona almeno un pallet"
                >
            </td>
        </tr>
    </nmscript>
</cfoutput>
