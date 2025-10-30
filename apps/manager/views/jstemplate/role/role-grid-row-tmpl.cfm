<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="role-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
             <td>
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td class="text-center">
                #iconButton(bind="click:edit", icon="edit")#
            </td>
        </tr>
    </nmscript>
</cfoutput>