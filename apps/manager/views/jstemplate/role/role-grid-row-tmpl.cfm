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
            <td>
                <span data-bind="text: type.name"></span>
                <span class="small-code">(<span data-bind="text: type.id"></span>)</span>
            </td>
            <td class="text-end">
                <span data-bind="text: minQuantity"></span>
            </td>
            <td class="text-end">
                <span data-bind="text: maxQuantity"></span>
            </td>
            <td class="text-end">
                <span data-bind="text: quotationMaxAmount"></span>
            </td>
            <td class="text-end">
                <span data-bind="text: quotationMaxDiscount"></span>
            </td>
            <td class="text-center">
                #iconButton(bind="click:editPermissions", icon="key")#
            </td>
            <td class="text-center">
                #iconButton(bind="click:edit", icon="edit")#
            </td>
        </tr>
    </nmscript>
</cfoutput>