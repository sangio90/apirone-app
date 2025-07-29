<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="product-combinations-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <span data-bind="text: name"></span>
            </td>
            <td class="text-center">
				<button type="button" class="btn btn-default btn-sm" data-bind="click:openImagesList" data-type="combination">
					<i class="fas fa-image"></i>
				</button>
            </td>
            <td class="text-center">
                <input type="checkbox" class="form-check-input"
                    name="selected"
                    value="##: id ##"
                >
            </td>
        </tr>
    </nmscript>
</cfoutput>