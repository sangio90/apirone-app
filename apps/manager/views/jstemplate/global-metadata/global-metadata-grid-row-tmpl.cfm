<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="global-metadata-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
             <td>
                <span data-bind="text: id"></span>
            </td>
            <td>
                <span data-bind="text: type.name"></span>
				<span class="small-code">(<span data-bind="text: type.code"></span>)</span>
            </td>
            <td>
                <span data-bind="text: getCreatedAt"></span>
            </td>
            <td>
                <span data-bind="text: type.measurementUnit.name"></span>
				<span class="small-code">(<span data-bind="text: type.measurementUnit.id"></span>)</span>
            </td>
            <td>
				<input data-bind="value: value" type="text" class="form-control"/>
            </td>
        </tr>
    </nmscript>
</cfoutput>