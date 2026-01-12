<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="line-cost-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: category.name"></span>
            </td>
            <td>
                <span data-bind="text: line.name"></span>
            </td>
            <td>
                <span data-bind="text: finish.name"></span>
            </td>
            <td class="text-center d-flex justify-content-start">
                <input type="text" class="form-control text-end" name="cost_##: id ##" 
                    data-bind="value: cost" style="width: 100px;"> <div class="ms-2 mt-2">&euro;</div>
            </td>
            <!---
            <td class="text-center">
                <input type="checkbox" class="form-check-input"
                    name="selected"
                    value="##: id ##"
                >
            </td>
        --->
        </tr>
    </nmscript>

</cfoutput>