<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>

	<nmscript type="text/x-kendo-template" id="font-family-pictogram-size-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td>
                <div data-bind="text: id"></div>
            </td>
            <td>
                <span data-bind="text: fontFamilySize.name"></span>
                <span class="small-code">(<span data-bind="text: fontFamilySize.id"></span>)</span>
            </td>
            <td class="">
                <div class="d-flex align-items-center">
    				<input name="width_##:uid##" class="form-control width-100 text-end me-2" data-bind="value: width"> <span>px</span>
                </div>
            </td>
            <td>
                <div class="d-flex align-items-center">
    				<input name="height_##:uid##" class="form-control width-100 text-end me-2" data-bind="value: height"> <span>px</span>
                </div>
            </td>
            <td class="width-40">
				-
            </td>
        </tr>
    </nmscript>

</cfoutput>

