<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="raw-value-suggest-row-tmpl">
        <span class="value-suggest-row" style="display: flex; align-items: center;">
            <div class="label-item-col" style="width:60px;">##: id ##</div> <!--- not works with data-bind, so using static text --->
            <div class="label-item-col" style="width:60px;">##: code ##</div>
            <div class="label-item-col" style="width:250px;">##: name ##</div>
        </span>
    </nmscript>
</cfoutput>