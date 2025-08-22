<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="metadata-type-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: code"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td>
                <span data-bind="text: dataType.name"></span>
                <span class="small-code">(<span  data-bind="text: dataType.id"></span>)</span>
            </td>
            <td>
                <span data-bind="text: measurementUnit.name"></span>
                <span class="small-code">(<span  data-bind="text: measurementUnit.id"></span>)</span>
            </td>
            <td>
                <div data-bind="source: entities" data-template="entity-row-tmpl"></div>
            </td>
            <td class="text-center">
                #iconButton(bind="click:edit", icon="edit")#
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input" name="selected"
                    value="##: id ##"
                >                    
            </td>
        </tr>
    </nmscript>

    #template( view="jstemplate/metadata-type/entity-row-tmpl" )#

</cfoutput>