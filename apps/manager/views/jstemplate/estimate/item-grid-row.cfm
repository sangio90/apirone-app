<cfoutput>
    <nmscript type="text/x-kendo-template" id="estimate-item-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text:type.name"></span>
            </td>
            <td>
                <span data-bind="text:capacity.name"></span>
            </td>
            <td>
                <span data-bind="text:quantity"></span>
            </td>
        </tr>
    </nmscript>
</cfoutput>
