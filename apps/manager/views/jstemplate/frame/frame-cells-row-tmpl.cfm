<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    
	<nmscript type="text/x-kendo-template" id="frame-cells-row-tmpl">

		<div data-bind="source: cells" data-template="frame-cells-col-tmpl" class="frame-grid-row">
		</div>

    </nmscript>

	#template( view="jstemplate/frame/frame-cells-col-tmpl" )#

</cfoutput>