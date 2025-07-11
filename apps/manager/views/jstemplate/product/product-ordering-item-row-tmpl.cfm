<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="product-ordering-item-row-tmpl">
        <tr class="k-master-row id-##: id ##" data-uid="##: uid ##" data-id="##: id ##" data-level="##: level ##" data-attribute="##: attribute.id ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: id"></span>
            </td>
            <td class="hand sortable">
                <span data-bind="html: spaces"></span>
                <span data-bind="html: orderby"></span>
                <span data-bind="html: level"></span>
                <span data-bind="text: attribute.name"></span>: 
                <span data-bind="text: attributeValue.rawValue.name"></span>
            </td>
            <td>
                <span class="handler">
                    &nbsp;
                </span>
            </td>
        </tr>
    </nmscript>
</cfoutput>