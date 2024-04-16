<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="shipment-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text:shortId"></span>
            </td>
            <td>
                <span data-bind="text:account.email"></span>
            </td>
            <td class="with-bg ##: tracking.status.class ##">
                <span data-bind="text:tracking.status.id"></span>
            </td>
            <td>
                <span data-bind="text:shipper.name"></span> 
            </td>
            <td>
                <span data-bind="text:area.name"></span> 
            </td>
            <td>
                <span data-bind="text:serviceType.name"></span>
            </td>
            <td>
                <span data-bind="text:type.name"></span>
            </td>
            <td>
                <span data-bind="text:getDate"></span>
            </td>
            <td>
                <span data-bind="text:delivery.location.postalCode"></span> - 
                <span data-bind="text:delivery.location.city"></span>
                (<span data-bind="text:delivery.location.county.id"></span>)
                <span data-bind="text:delivery.location.country.name"></span>
            </td>
            <td align="right">
                <span data-bind="text:total" data-format="c2"></span>
            </td>
            <td align="right" style="background-color: \##f4f4f4;">
                <span data-bind="text:isPickupWithPallet"></span>
            </td>
            <td align="right" style="background-color: \##f4f4f4;">
                <span data-bind="text:pickupPallet.code"></span>
            </td>
            <td align="right">
                <span data-bind="text:deliveryPallet.code"></span>
            </td>
            <td>
                <div>
                    <a href="/manager/shipment/##: id ##" target="_blank">
                        <i class="fa-solid fa-pen-to-square"></i>
                    </a>
                </div>
            </td>
            <td>
                <div>
                    <input type="checkbox" class="form-check-input"
                        name="selected"
                        data-bind="value:id" 
                    >
                </div>
            </td>

        </tr>
    </nmscript>
</cfoutput>

<!----
    <cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="shipment-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text:shortId"></span>
            </td>
            <td>
                <span data-bind="text:account.email"></span>
            </td>
            <td class="with-bg ##: tracking.status.class ##">
                <span data-bind="text:tracking.status.id"></span>
            </td>
            <td>
                <span data-bind="text:shipper.name"></span> 
            </td>
            <td>
                <span data-bind="text:area.name"></span> 
            </td>
            <td>
                <span data-bind="text:serviceType.name"></span>
            </td>
            <td>
                <span data-bind="text:getDate"></span>
            </td>
            <td>
                <span data-bind="text:prefLocation.location.postalCode"></span>
                <span data-bind="text:prefLocation.location.city"></span>
                (<span data-bind="text:prefLocation.location.county.id"></span>)
                <span data-bind="text:prefLocation.location.country.name"></span>
            </td>
            <td align="right" style="background-color: \##f4f4f4;">
                <span data-bind="text:isPickupWithPallet"></span>
            </td>
            <td align="right" style="background-color: \##f4f4f4;">
                <span data-bind="text:pallet.code"></span>
            </td>
            <td>
                <div>
                    <a href="/manager/shipment/##: id ##" target="_blank">
                        <i class="fa-solid fa-pen-to-square"></i>
                    </a>
                </div>
            </td>
            <td>
                <div>
                    <input type="checkbox" class="form-check-input"
                        name="selected"
                        data-bind="value:id" 
                    >
                </div>
            </td>

        </tr>
    </nmscript>
</cfoutput>
---->