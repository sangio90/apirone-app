<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="product-components-selected-list-row-tmpl">
        <tr>
            <td>
                <b data-bind="text: id"></b>
                <span data-bind="text: name"></span>
            </td>
            <td width="40">
                <button class="btn"><i class="fa fa-trash"></i></button>
            </td>
        </tr>
    </nmscript>
</cfoutput>