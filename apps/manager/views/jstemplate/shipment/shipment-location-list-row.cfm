<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="shipment-location-list-row-tmpl">
        <tr>
            <td><span data-bind="text: contactPerson"></span></td>
            <td><span data-bind="text: address"></span></td>
            <td>
                <span data-bind="text: city"></span>
                (<span data-bind="text: postalCode"></span>)
            </td>
            <td><span data-bind="text: county.id"></td>
            <td><span data-bind="text: country.name"></td>
            <td>
                <input type="button" value="Seleziona" class="btn btn-primary" data-bind="click:useLocation">
            </td>
        </tr>
    </nmscript>
</cfoutput>