<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="component-selected-row-tmpl">
        <tr  ##if (type == 'base') {## class="bg-blue" ##}## >
            <td width="10">
                <b data-bind="text: rawProduct.processingType.id"></b>
                <br>
                <i>(<span data-bind="text: id"></span>)</i>
            </td>
            <td>
                <b data-bind="text: rawProduct.id"></b><br>
                <span data-bind="text: rawProduct.name"></span>
            </td>
            <td>
                <b data-bind="text: variant.id"></b><br>
                <span data-bind="text: variant.name" style="line-height: 19px"></span>
            </td>
            <td>
                <b data-bind="text: color.id"></b><br>
                <span data-bind="text: color.name"></span>
            </td>
            <td width="70">
                <input data-bind="value: quantity" class="form-control text-end" style="width:80px">
                <span data-bind="text: rawProduct.measurementUnit.id"></span>
            </td>
            <td width="40" class="text-end">
                #iconButton( icon="trash", bind="click:remove" )#
            </td>
        </tr>
    </nmscript>
</cfoutput>