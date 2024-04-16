<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="country-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span>##: id.slice(-6) ##</span>
            </td>
            <td>
                <span data-bind="text:code"></span>
            </td>
            <td>
                <input type="text" class="form-control"
                    data-bind="value:name" 
                    data-rule-required="true"
                    data-msg-required="Descrizione richiesta"
                >
            </td>
            <td>
                <span data-bind="text:area.name"></span>
            </td>
            <!----
            <td>
                <div data-bind="source: serviceTypes" data-template="country-grid-row-service-tmpl">
                </div>
            </td>
            ----->
            <td>
                <div style="display: flex; justify-content: flex-start">
                    <div class="color" style="background-color: ##: status.color.hex ##; width: 10px; height: 10px; margin-right: 5px; margin-top: 6px;">&nbsp;</div>
                    <div data-bind="text:status.name"></div>
                </div>
            </td>
            <td>
                <div>
                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:edit">
                        <i class="fa-solid fa-pen-to-square"></i>
                    </button>
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