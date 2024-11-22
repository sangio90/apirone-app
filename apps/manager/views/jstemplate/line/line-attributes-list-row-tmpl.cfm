<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="line-attributes-list-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: shortId"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td class="text-center">
                <button type="button" class="btn btn-default btn-sm" data-bind="click:selectAttribute">
                    <i class="fas fa-plus"></i> 
                </button>
            </td>
            <td class="text-center">
                <button type="button" class="btn btn-default btn-sm" data-bind="click:showAttributeValues">
                    <i class="fas fa-eye"></i> 
                </button>
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input" name="selected"
                    data-bind="value:id" 
                >                    
            </td>
        </tr>
    </nmscript>
</cfoutput>