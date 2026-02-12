<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="quotation-item-article-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td class="text-center">
                <div class="btn btn-default btn-sm" data-bind="click:edit" data-id="##:id##"  title="Modifica">
                    <i class="fas fa-edit" style="cursor: pointer"></i>
                </div>
                <div class="btn btn-default btn-sm" data-bind="click:delete" data-id="##:id##"  title="Cancella">
                    <i class="fas fa-trash" style="color: red; cursor: pointer"></i>
                </div>
            </td>
            <td>
                <span data-bind="text: article.code"></span>
            </td>
            <td>
                <span data-bind="text: article.name"></span>
            </td>
            <td style="text-align: right;">
                <span data-bind="text: quantity" data-format="n2"></span>
            </td>
            <td style="text-align: right;">
                <span data-bind="text: price.total" data-format="n2"></span> &euro;
            </td>
        </tr>
    </nmscript>
</cfoutput>