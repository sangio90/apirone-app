<cfoutput>
    <nmscript type="text/x-kendo-template" id="calculate-cost-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <input name="" data-bind="value: description" class="form-control" placeholder="">
            </td>
            <td>
                <input name="" data-bind="value: xx" class="form-control" placeholder="">
            </td>
            <td>
                <input name="" data-bind="value: yy" class="form-control" placeholder="">
            </td>
            <td width="100">
                <input name="" data-bind="value: hh" class="form-control" placeholder="0.75">
            </td>
            <td width="100">
                <input name="" data-bind="value: pp" class="form-control" placeholder="">
            </td>            
            <td width="100">
                <input name="" data-bind="value: cc" class="form-control" placeholder="Costo">
            </td>
            <td width="50">
                <i class="fa-solid fa-trash" data-bind="click:deleteFormRow"></i>
            </td>
        </tr>
    </nmscript>
</cfoutput>
