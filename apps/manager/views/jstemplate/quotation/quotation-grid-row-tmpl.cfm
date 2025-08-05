<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="quotation-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: description"></span>
            </td>
            <td>
                <span data-bind="text: quotationNumber"></span>/<span data-bind="text: versionNumber"></span>
            </td>
            <td>
                ##= kendo.toString(quotationDate, "dd/MM/yyyy") ##
            </td>
            <td>
                <span data-bind="text: status.name"></span>
            </td>
        </tr>
    </nmscript>
</cfoutput>