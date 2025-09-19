<cfoutput>
    <nmscript type="text/x-kendo-template" id="frame-grid-row-tmpl">
        <tr class="k-master-row" data-uid="##: uid ##">
            <td style="border-left: 4px solid ##=status.color.hex##">
				<span data-bind="text: shortId"></span>
			</td>
			<td>
				<span data-bind="text: code"></span>
			</td>
			<td>
				<span data-bind="text: frame"></span>
			</td>
			<td>
				<span data-bind="text: orientation.name"></span>
			</td>
			<td>
				<span data-bind="text: cellOrientation.name"></span>
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
</cfoutput>