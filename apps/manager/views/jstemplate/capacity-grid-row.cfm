<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="capacity-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text:id"></span>
            </td>
            <td>
                <input type="text" class="form-control"
                    data-bind="value:name" 
                    data-rule-required="true"
                    data-msg-required="Descrizione richiesta"
                >
            </td>
            <td>
                <input type="text" class="form-control text-end"
                    data-bind="value:value" 
                    data-rule-required="true"
                    data-rule-number="true"
                    data-msg-required="Litri richiesti"
                    data-msg-integer="Richiesto un valore numerico"
                >
            </td>
            <td>
                <span data-bind="text:created"></span>
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