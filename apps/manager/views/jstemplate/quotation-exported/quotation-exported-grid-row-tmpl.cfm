<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="quotation-exported-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##" style="font-size: 11px">
            <td>
                <span class="company" data-bind="text: company"></span>
            </td>
            <td>
                <span class="quotationSerial" data-bind="text: quotationSerial"></span>
            </td>
            <td>
                <span class="quotationCode" data-bind="text: quotationCode"></span>
            </td>
            <td>
                <span data-bind="text: billingAddress"></span>
            </td>
            <td>
                <span data-bind="text: shippingAddress"></span>
            </td>
            <td>
                <span data-bind="text: opportunity"></span>
            </td>
            <td>
                <span data-bind="text: agent"></span>
            </td>
            <td class="text-center">
                #iconButton(bind="click:edit", class="btn-primary", icon="list")#
                #iconButton(bind="click:delete", class="btn-danger", icon="trash")#
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input"
                    name="selected"
                    value="##: key ##"
                >
            </td>
        </tr>
    </nmscript>
</cfoutput>