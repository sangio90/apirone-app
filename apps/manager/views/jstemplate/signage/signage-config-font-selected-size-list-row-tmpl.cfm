<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="signage-config-font-selected-size-list-row-tmpl">
        <tr class="k-master-row">
            <td width="50">
                <span data-bind="text: id"></span>
            </td>
            <td width="55%">
                <div class="d-flex align-items-center">
                    [<span data-bind="text: height"></span>]
                    <select 
                        class="form-control width-150 ms-1"
                        data-text-field="name"
                        data-value-field="id"
                        data-rule-required="true"
                        data-msg="Altezza font richiesta"
                        data-bind="source: getFontFamilySizes, value: size"
                    >
                    </select>
                    
                </div>
            </td>
            <td width="15%">
                <div class="d-flex align-items-center mr-1">
                    <input type="text" class="form-control width-70 me-1" name="heightInPx_##:uid##"
                        data-bind="value: heightInPixel"
                        data-rule-required="true"
                        data-rule-number="true"
                        data-msg="Altezza in px richiesta e non valida"
                    >
                    <span>px</span>
                </div>
            </td>
            <td width="15%">
                <input type="text" class="form-control width-70" name="rowCount_##:uid##"
                    data-bind="value: rowCount" 
                    data-rule-required="true"
                    data-rule-number="true"
                    data-msg="Numero di righe richiesto e non valido"
                >
            </td>
            <td width="15%">
                <input type="text" class="form-control width-70" name="charCount_##:uid##"
                    data-bind="value: charCount" 
                    data-rule-required="true"
                    data-rule-number="true"
                    data-msg="Numero di caratteri richiesto e non valido"
                >
            </td>
            <td class="text-center min-width-50">
                <button type="button" class="btn btn-default btn-sm" 
                    data-bind="click:openComponentsList, visible:showComponentButton" 
                    data-type="signageConfigItem"> 
                    <i class="fas fa-window-restore"></i> 
                </button>                
            </td>
            <td class="text-center min-width-50">
                <button type="button" class="btn btn-default btn-sm" 
                    data-bind="click:openComponentWithItems, visible:showComponentButton" 
                    data-type="signageConfigItem"> 
                    <i class="far fa-window-restore"></i> 
                </button>                
            </td>
            <td class="text-center min-width-50">
                #iconButton(bind="click:delete", icon="trash")#
            </td>
        </tr>
    </nmscript>

</cfoutput>
