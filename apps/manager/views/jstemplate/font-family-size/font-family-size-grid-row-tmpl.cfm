<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="font-family-size-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <input type="number" class="form-control" data-bind="value: name, disabled: id" style="width: 15%"/>
            </td>
            <td class="text-center">
                #iconButton(bind="click:removeSize", class="btn-danger", icon="trash")#
            </td>
        </tr>
    </nmscript>

</cfoutput>

