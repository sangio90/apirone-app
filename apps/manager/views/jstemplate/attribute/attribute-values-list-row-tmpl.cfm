<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="attribute-values-list-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text:rawValue.code"></span>
            </td>
            <td class="sortable">
                <span data-bind="text:rawValue.name"></span>
            </td>
            <td class="text-center">
                <input type="checkbox" data-bind="checked: allowNote" name="allowNote" class="form-check-input">
            </td>
            <td class="text-center">
                <input type="checkbox" data-bind="checked: affectToImage" name="affectToImage" class="form-check-input">
            </td>
            <td class="text-center">
                <button type="button" class="btn btn-default btn-sm" data-bind="click:openComponentsList" data-type="attributeValue"> 
                    <i class="fas fa-window-restore"></i> 
                    <i class="button-badge info" data-bind="text: componentCount"></i> 
                </button>
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input" name="selected" value="##=id##">
            </td>
        </tr>
    </nmscript>
</cfoutput>