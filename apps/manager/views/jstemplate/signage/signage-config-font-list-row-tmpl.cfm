<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="signage-config-font-list-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: code"></span>
            </td>
            <td>
                <span data-bind="text: nameItem.name"></span>
            </td>
            <td>
                <span data-bind="text: fontFamily.name"></span>
            </td>
            <td class="text-end">
                #iconButton(bind="click:add", icon="angle-right")#
            </td>
        </tr>
    </nmscript>

</cfoutput>

