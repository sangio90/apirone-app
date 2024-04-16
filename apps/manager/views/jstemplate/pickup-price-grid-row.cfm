<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="pickup-price-grid-row-tmpl">
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
                <input type="text" class="form-control"
                    data-bind="value:quantity" 
                    data-rule-required="true"
                    data-rule-integer="true"
                    data-msg-required="Bottiglie richieste"
                    data-msg-integer="Richiesto un valore intero"
                >
            </td>
            <td>
                <div class="row">
                    <div class="col-4">
                        <input type="text" class="form-control"
                            data-bind="value:price.value" 
                            data-rule-required="true"
                            data-rule-number="true"
                            data-msg-required="Prezzo richiesto"
                            data-msg-number="Richiesto un valore numerico"
                        >
                    </div>
                    
                    <div class="col-4">
                        <select type="text" class="form-control col-8"
                            data-bind="value:price.type.id" 
                        >
                            <option value="F">Fisso</option>
                            <option value="P">%</option>
                        </select>
                    </div>
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