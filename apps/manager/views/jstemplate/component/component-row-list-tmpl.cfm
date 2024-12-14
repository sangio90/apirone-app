<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="component-row-list-tmpl">
        <tr>
            <td>
                <b data-bind="text: id"></b><br>
                <span data-bind="text: name"></span>
            </td>
            <td class="text-center">

                #iconButton( bind="click:openVariants", size="sm", icon="chevron-right", variant="default" )#
                
                <!---
                <span data-bind="visible: showVariantsForCount">
                    #iconButton( bind="click:openVariants", size="sm", icon="chevron-right", variant="default" )#
                </span>

                <span data-bind="invisible: showVariantsForCount">
                    #addButton( bind="click:useComponent", label="Aggiungi", size="sm", variant="default")#
                </span>
                ---->
            
            </td>
        </tr>
    </nmscript>
</cfoutput>