<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="sign-config-font-selected-size-list-row-tmpl">
        <tr class="k-master-row">
            <td width="50">
                <span data-bind="text: id"></span>
            </td>
            <td width="20%" class="align-end align-top">
                <input type="text" class="form-control w-70" data-bind="value: height" name="height"
                    data-rule-required="true"
                    data-rule-number="true"
                    data-msg="Altezza in mm richiesta o non valida"
                >
            </td>
            <td width="20%" class="align-end align-top">
                <input type="text" class="form-control w-70" data-bind="value: heightInPx" name="heightInPx"
                    data-rule-required="true"
                    data-rule-number="true"
                    data-msg="Altezza in px richiesta"
                >
            </td>
            <td width="20%" class="align-end align-top">
                <input type="text" class="form-control w-70" data-bind="value: rowCount" name="rowCount"
                    data-rule-required="true"
                    data-rule-number="true"
                    data-msg="Numero di righe richiesto"
                >
            </td>
            <td width="20%" class="align-end align-top">
                <input type="text" class="form-control w-70" data-bind="value: charCount" name="charCount"
                    data-rule-required="true"
                    data-rule-number="true"
                    data-msg="Numero di caratteri richiesto"
                >
            </td>
            <td width="50" class="text-center">
                #iconButton(bind="click:delete", icon="trash")#
            </td>
        </tr>
    </nmscript>

</cfoutput>

