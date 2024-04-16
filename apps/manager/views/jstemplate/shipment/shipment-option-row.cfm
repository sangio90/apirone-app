<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="shipment-option-row-tmpl">
        <tr data-uid="##: uid ##">
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td align="right">
                <span data-bind="text: amount, visible: showRemoveOption" data-format="c2"></span>
            </td>
            <td align="right" width="40">
                <div id="opt-status_##: uid ##"></div>
            </td>
            <td align="right" width="120">
                <button  type="button" class="btn btn-sm btn-success" data-bind="click:addOption, visible: showAddOption">
                    <i class="fa fa-plus"></i> AGGIUNGI
                </button>
                
                <button type="button" class="btn btn-sm btn-danger" data-bind="click:removeOption, visible: showRemoveOption">
                    <i class="fa fa-minus"></i> RIMUOVI
                </button>
            </td>
        </tr>
    </nmscript>
</cfoutput>

