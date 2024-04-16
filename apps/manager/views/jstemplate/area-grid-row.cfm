<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="area-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td width="50">
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
                <div>
                    <button type="button" class="btn btn-primary btn-sm" data-bind="click:edit">
                        <i class="fa-solid fa-pen-to-square"></i>
                    </button>
                </div>
            </td>
        </tr>
    </nmscript>
</cfoutput>