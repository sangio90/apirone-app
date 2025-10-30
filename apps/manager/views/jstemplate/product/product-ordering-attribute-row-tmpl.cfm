<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="product-ordering-attribute-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##" data-id="##: id ##" data-level="##: level ##">
            <td>
                <span data-bind="text: shortId"></span>
            </td>
            <td class="hand sortable">
                <span data-bind="html: spaces"></span>
                <span data-bind="html: level"></span>
                <span data-bind="text: name"></span> 
            </td>
            <td>
                <span class="handler">
                    &nbsp;
                </span>
            </td>
        </tr>
    </nmscript>
</cfoutput>