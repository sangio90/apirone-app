<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="product-item-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="html: spaces"></span>
                <b data-bind="text: attribute.name" class="fs-10"></b>: 
                <span data-bind="text: attributeValue.rawValue.name"></span>
            </td>

            <!--- attivo --->
            ##if (status.id == 'ACT') {## 

                <td>
                    <div style="display: flex; align-items: center; justify-content: flex-end;" data-bind="events: { click: editPrices }">
                        <div data-bind="source: prices" data-template="price-row-tmpl" class="flex: 1">
                        </div>
                        <div style="width: 30px; flex-shrink: 0;">#iconButton(icon="euro-sign")#</div>
                    </div>
                </td>
                <td class="text-center">
                    <button type="button" class="btn btn-default btn-sm" data-bind="click:openImagesList" data-type="productItem">
                        <i class="fas fa-image"></i> 
                    </button>
                </td>

                <td class="text-center">
                    <button type="button" class="btn btn-default btn-sm" data-bind="click:openAttributesList, attr: { data-origin-id: id }">
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
                        name="important"
                        data-bind="checked: important"
                        value="##: id ##"
                    >
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
                        <i class="fas fa-chevron-right"></i>
                    </button>
                </td>
            
            ##}##
        </tr>
    </nmscript>
    
    #template( view="jstemplate/price/price-row-tmpl" )#

</cfoutput>