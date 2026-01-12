<cfprocessingdirective pageEncoding="UTF-8">

<nmscript type="text/template" id="text-status-row-tmpl">
    <div>
        <span data-bind="css: { translated: isTranslated, untranslated: isUntranslated }" class="status-translation">&nbsp;</span>
        <span data-bind="text: lang.name"></span>
    </div>
</nmscript>
