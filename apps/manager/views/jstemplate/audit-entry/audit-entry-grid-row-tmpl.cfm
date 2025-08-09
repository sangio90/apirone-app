<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="audit-entry-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: getCreatedAt"></span>
            </td>
            <td>
                <span data-bind="text: entity"></span>
            </td>
            <td>
                <span data-bind="text: action"></span>
            </td>
            <td>
                <span data-bind="text: message"></span>
            </td>
            <td>
                <span data-bind="text: account.name"></span>
                (<span data-bind="text: account.shortId"></span>)
            </td>
            <td class="text-center">
                #iconButton(bind="click:show", icon="eye")#
            </td>
        </tr>
    </nmscript>

</cfoutput>