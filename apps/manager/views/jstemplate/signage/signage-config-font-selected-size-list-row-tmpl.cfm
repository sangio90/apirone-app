<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="signage-config-font-selected-size-list-row-tmpl">
        <tr class="k-master-row">
            <td width="30">
                <span data-bind="text: id"></span>
            </td>
            <td width="20%" class="align-end align-top">
                <input type="text" class="form-control w-70" name="height_##:uid##"
                    data-bind="value: height" 
                    data-rule-required="true"
                    data-rule-number="true"
                    data-msg="Altezza in mm richiesta e non valida"
                >
            </td>
            <td width="20%" class="align-end align-top">
                <input type="text" class="form-control w-70" name="heightInPx_##:uid##"
                    data-bind="value: heightInPixel"
                    data-rule-required="true"
                    data-rule-number="true"
                    data-msg="Altezza in px richiesta e non valida"
                >
            </td>
            <td width="20%" class="align-end align-top">
                <input type="text" class="form-control w-70" name="rowCount_##:uid##"
                    data-bind="value: rowCount" 
                    data-rule-required="true"
                    data-rule-number="true"
                    data-msg="Numero di righe richiesto e non valido"
                >
            </td>
            <td width="20%" class="align-end align-top">
                <input type="text" class="form-control w-70" name="charCount_##:uid##"
                    data-bind="value: charCount" 
                    data-rule-required="true"
                    data-rule-number="true"
                    data-msg="Numero di caratteri richiesto e non valido"
                >
            </td>
            <td width="50" class="text-center">
                #iconButton(bind="click:delete", icon="trash")#
            </td>
        </tr>
    </nmscript>

</cfoutput>
