<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="quotation-status-history-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: createdAt"></span>
            </td>
            <td>
                <span data-bind="text: account"></span>
            </td>
            <td>
                <span data-bind="text: status"></span>
            </td>
            <td class="text-center">
                <span 
                    class="btn btn-default btn-sm" 
                    id="documentDownloadButton" 
                    data-bind="click: download, visible: fileName"
                >
                    <i class="fas fa-download"></i>
                </span>
            </td>
        </tr>
    </nmscript>
</cfoutput>