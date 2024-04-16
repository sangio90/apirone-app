<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="shipment-profile-list-row-tmpl">
        <tr>
            <td><span data-bind="text: shortId"></span></td>
            <td><span data-bind="text: name"></span></td>
            <td><span data-bind="text: location.address"></span></td>
            <td>
                <span data-bind="text: location.city"></span>
                (<span data-bind="text: location.postalCode"></span>)
            </td>
            <td><span data-bind="text: location.country.name"></td>
            <td><span data-bind="text: customerType.name"></td>
            <td><span data-bind="text: vat"> <span data-bind="text: fiscalCode"></td>
            <td>
                <input type="button" value="Seleziona" class="btn btn-primary" data-bind="click:useProfile">
            </td>
        </tr>
    </nmscript>
</cfoutput>
