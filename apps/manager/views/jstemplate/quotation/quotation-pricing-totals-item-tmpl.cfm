<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="quotation-pricing-totals-item-tmpl">
		<tr>
			<td>
				<span data-bind="text: name"></span>
			</td>
			<td width="30" class="text-end">
				<span data-bind="text: amount"></span>
			</td>
		</tr>
    </nmscript>

</cfoutput>