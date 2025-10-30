<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="fruit-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: shortId"></span>
            </td>
            <td>
                <span data-bind="text: code"></span>
            </td>
            <td>
                <span data-bind="text: nameItem.name"></span>
            </td>
            <td>
                <span data-bind="text: category.name"></span>
            </td>
            <td>
                <div data-bind="source: lines" data-template="fruit-line-row-tmpl"></div>
            </td>
            <td class="text-end">
                <span data-bind="text: positionCount"></span>
            </td>
            <td class="text-center">
                #iconButton(bind="click:attributes", icon="external-link-square-alt")#
            </td>
            <td class="text-center">
                #iconButton(bind="click:edit", icon="edit")#
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input"
                    name="selected"
                    value="##: id ##"
                >
            </td>
        </tr>
    </nmscript>

    #template( view="jstemplate/fruit/fruit-line-row-tmpl" )#
    
</cfoutput>
