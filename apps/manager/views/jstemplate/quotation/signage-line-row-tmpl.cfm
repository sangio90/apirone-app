<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="signage-line-row-tmpl">
        <div class="border rounded p-3 mb-3">
            <div class="mb-3 row">
                <div class="col-9">
                    <button type="button" class="btn btn-danger btn-sm" data-bind="click:removeSignageLine">
                        <i class="fas fa-trash"></i> Elimina
                    </button>
                </div>
                <div class="col-3 text-end">
                    <i class="fas fa-align-left text-md mx-2 selected-text-align" data-value="left" data-bind="click:setTextAlign"></i>
                    <i class="fas fa-align-center text-md mx-2 selected-text-align-not" data-value="center" data-bind="click:setTextAlign"></i>
                    <i class="fas fa-align-right text-md mx-2 selected-text-align-not" data-value="right" data-bind="click:setTextAlign"></i>
                </div>
            </div>
            <div class="mb-3 row">
                <div class="col-12">
                    <input type="text" class="form-control" placeholder="Testo" data-bind="value:content, events: { change: parsedLineContent }" placeholder="Inserisci qui il contenuto della riga">
                </div>
            </div>
        </div>
    </nmscript>
</cfoutput>