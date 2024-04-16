<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="pallet-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text:shortId"></span>
            </td>
            <td class="with-bg ##: tracking.status.class ##">
                <span data-bind="text:tracking.status.name"></span>
            </td>            
            <td>
                <span data-bind="text:code"></span>
            </td>
            <td>
                <span data-bind="text:type.name"></span>
            </td>

            <td>
                <span data-bind="text:getDate"></span>
            </td>
            <td>
                <div>
                    <a href="/manager/pallets/##: id ##" target="_blank">
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