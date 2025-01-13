<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="component-selected-row-tmpl">
        <tr>
            <td width="10">
                <b data-bind="text: comp.processingType.id"></b>
            </td>
            <td class="text-truncate">
                <b data-bind="text: comp.id"></b><br>
                <span data-bind="text: comp.name"></span>
            </td>
            <td class="text-truncate">
                <b data-bind="text: variant.id"></b><br>
                <span data-bind="text: variant.name"></span>
            </td>
            <td class="text-truncate">
                <b data-bind="text: color.id"></b><br>
                <span data-bind="text: color.name"></span>
            </td>
            <td width="100">
                <input data-bind="value: quantity" class="form-control text-end">
            </td>
            <td width="40" class="text-end">
                #iconButton( icon="trash", bind="click:removeComponent" )#
            </td>
        </tr>
    </nmscript>
</cfoutput>