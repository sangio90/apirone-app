<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="attribute-values-list-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: id"></span>
            </td>
            <td class="sortable">
                <span data-bind="text:mainText.name"></span>
                -<span data-bind="text:orderBy"></span>-
            </td>
            <td class="text-center">
                <button type="button" class="btn btn-primary btn-sm" data-bind="click:editValue">
                    <i class="fas fa-eye"></i>
                </button>
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input"
                    name="selected"
                    data-bind="value:id" 
                >
            </td>
        </tr>
    </nmscript>
</cfoutput>