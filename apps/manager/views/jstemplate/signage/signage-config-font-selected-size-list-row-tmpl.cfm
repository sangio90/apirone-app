<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="signage-config-font-selected-size-list-row-tmpl">
        <tr class="k-master-row">
            <td width="50">
                <span data-bind="text: id"></span>
            </td>
            <td class="align-end align-top" width="30%">
                -<span data-bind="text: size.id"></span>-
                <select 
                    class="form-control"
                    data-text-field="name"
                    data-value-field="id"
                    data-bind="source: getFamilySizes, value: size"
                >
                </select>
            </td>
            <td class="align-end align-top" width="20%">
                <input type="text" class="form-control width-70" name="heightInPx_##:uid##"
                    data-bind="value: heightInPixel"
                    data-rule-required="true"
                    data-rule-number="true"
                    data-msg="Altezza in px richiesta e non valida"
                >
            </td>
            <td class="align-end align-top" width="25%">
                <input type="text" class="form-control width-70" name="rowCount_##:uid##"
                    data-bind="value: rowCount" 
                    data-rule-required="true"
                    data-rule-number="true"
                    data-msg="Numero di righe richiesto e non valido"
                >
            </td>
            <td class="align-end align-top" width="25%">
                <input type="text" class="form-control width-70" name="charCount_##:uid##"
                    data-bind="value: charCount" 
                    data-rule-required="true"
                    data-rule-number="true"
                    data-msg="Numero di caratteri richiesto e non valido"
                >
            </td>
            <td class="text-center" width="50">
                <button type="button" class="btn btn-default btn-sm" 
                    data-bind="click:openComponentsList, visible:showComponentButton" 
                    data-type="signageConfigItem"> 
                    <i class="fas fa-window-restore"></i> 
                </button>                
            </td>
            <td class="text-center" width="50">
                #iconButton(bind="click:delete", icon="trash")#
            </td>
        </tr>
    </nmscript>

</cfoutput>
