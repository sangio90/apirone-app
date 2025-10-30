<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>

    <nmscript type="text/x-kendo-template" id="signage-config-item-product-item-list-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="html: spaces"></span>
                <b data-bind="text: attribute.name" class="fs-10"></b>: 
                <span data-bind="text: attributeValue.rawValue.name"></span>
            </td>
            <td class="text-center">
                <button type="button" class="btn btn-default btn-sm" data-bind="click:openComponentsList" data-type="item"> 
                    <i class="fas fa-window-restore"></i>
                    <i class="button-badge info" data-bind="text: componentCount"></i> 
                </button>
            </td>
        </tr>
    </nmscript>
    
</cfoutput>