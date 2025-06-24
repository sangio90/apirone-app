<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="combination-item-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="html: spaces"></span>
                <span data-bind="text: attribute.name"></span>: 
                <span data-bind="text: attributeValue.rawValue.name"></span>
            </td>

            <!--- attivo --->
            ##if (status.id == 'ACT') {## 

                <td class="text-center">
                    <button type="button" class="btn btn-default btn-sm" data-bind="click:openImagesList" data-type="combinationItem">
                        <i class="fas fa-image"></i> 
                    </button>
                </td>

                <td class="text-center">
                    <button type="button" class="btn btn-default btn-sm" data-bind="click:openAttributesList, attr: { data-parent-id: id }">
                        <i class="fas fa-plus"></i> 
                    </button>
                </td>
                <td class="text-center">
                    <button type="button" class="btn btn-default btn-sm" data-bind="click:openComponentsList" data-type="item"> 
                        <i class="fas fa-window-restore"></i>
                        <i class="button-badge info" data-bind="text: componentCount"></i> 
                    </button>
                </td>
                <td class="text-center">
                    <input type="checkbox" class="form-check-input"
                        name="selected"
                        value="##: id ##"
                    >
                </td>

            <!--- disattivo --->
            ##} else {##

                <td class="text-center">
                    <button type="button" class="btn btn-default btn-sm" data-bind="click:addValue">
                        <i class="fas fa-plus"></i> 
                    </button>
                </td>
            
            ##}##
        </tr>
    </nmscript>
</cfoutput>