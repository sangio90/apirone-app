<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="component-row-list-tmpl">
        <tr>
            <td>
                <b data-bind="text: id"></b><br>
                <span data-bind="text: name"></span>
            </td>
            <td class="text-center">

                #iconButton( bind="click:openVariants", size="sm", icon="chevron-right", variant="primary" )#
            
            </td>
        </tr>
    </nmscript>
</cfoutput>