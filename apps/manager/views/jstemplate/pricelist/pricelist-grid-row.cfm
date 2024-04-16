<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="pricelist-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td width="120">
                <span data-bind="text:id"></span>
            </td>
            <td>
                <input type="text" class="form-control"
                    data-bind="value:name" 
                    data-rule-required="true"
                    data-msg-required="Descrizione richiesta"
                >
            </td>
            <td width="48">
                <div>
                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:detail">
                        <i class="fa-solid fa-magnifying-glass-dollar"></i>
                    </button>
                </div>
            </td>
            <td width="28">
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