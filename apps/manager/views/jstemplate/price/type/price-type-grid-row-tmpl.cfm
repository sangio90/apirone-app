<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="price-type-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td>
				<div data-template="price-type-method-row-tmpl" data-bind="source: methods"></div>
            </td>
            <td>
				<div data-template="price-type-entity-row-tmpl" data-bind="source: entities"></div>
            </td>
            <td class="text-center">
                #iconButton(bind="click:edit", icon="edit")#
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input"
                    name="selected"
                    value="##: id ##"
                >
            </td>
        </tr>
    </nmscript>

	#template( "jstemplate/price/type/price-type-method-row-tmpl" )#
	#template( "jstemplate/price/type/price-type-entity-row-tmpl" )#

</cfoutput>