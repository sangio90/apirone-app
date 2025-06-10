<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="combination-ordering-item-row-tmpl">
        <tr class="k-master-row id-##: id ##" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="html: level"></span>
                <span data-bind="text: attribute.name"></span>: 
                <span data-bind="text: attributeValue.name"></span>
            </td>
            <td>
                <span class="hand"></span>
            </td>
        </tr>
    </nmscript>
</cfoutput>