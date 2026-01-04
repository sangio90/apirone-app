<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="quotation-status-history-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: status.name"></span>
                <span class="small-code">(<span data-bind="text: status.id"></span>)</span>
            </td>
            <td>
                <span data-bind="text: getCreatedAt"></span>
            </td>
            <td>
                <span data-bind="text: user.name"></span>
                <span class="small-code">(<span data-bind="text: user.shortId"></span>)</span>
            </td>
            <td class="text-center">
                <span class="btn btn-default btn-sm" 
                    data-bind="click: download, visible: file.id">
                    <i class="fas fa-download"></i>
                </span>
            </td>
            <td>
                <span class="btn btn-default btn-sm" 
                    data-bind="click: editFile, visible: file.id">
                    <i class="fas fa-edit"></i>
                </span>
            </td>

        </tr>
    </nmscript>
</cfoutput>