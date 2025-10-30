<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="line-category-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: shortId"></span>
            </td>
            <td>
                <span data-bind="text: code"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <!---
            <td>
                <input type="text" class="form-control" name="markup"
                    data-msg-required="height"
                    maxlength="125"
                    data-bind="value: markup">
            </td>
            ---->
            <td class="text-center">
                #iconButton(bind="click:showCloneModal", icon="copy")#
            </td>
            <td class="text-center">
                #iconButton(bind="click:products", icon="border-all")#
            </td>
            <td class="text-center">
                #iconButton(bind="click:attributes", icon="external-link-square-alt")#
            </td>
        </tr>
    </nmscript>

</cfoutput>