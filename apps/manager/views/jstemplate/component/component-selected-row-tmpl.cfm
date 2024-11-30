<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="component-selected-row-tmpl">
        <tr>
            <td nowrap>
                <b data-bind="text: comp.id"></b><br>
                <span data-bind="text: comp.name"></span>
            </td>
            <td nowrap>
                <b data-bind="text: variant.id"></b><br>
                <span data-bind="text: variant.name"></span>
            </td>
            <td nowrap>
                <b data-bind="text: color.id"></b><br>
                <span data-bind="text: color.name"></span>
            </td>
            <td>
                <button class="btn" data-bind="click: removeComponent"><i class="fa fa-trash"></i></button>
            </td>
        </tr>
    </nmscript>
</cfoutput>