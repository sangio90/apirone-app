<cfprocessingdirective pageEncoding="UTF-8">

<cfoutput>
    <nmscript type="text/x-kendo-template" id="signage-line-row-tmpl" data-id="##: id ##">
        <div class="border rounded p-3 mb-3 signage-row">
            <div class="mb-3 row">
                <div class="col-2 text-start">
                    Riga N°<span data-bind="text: index"></span>
                </div>
                <div class="col-6 pl-0-ml-3">
                    <button type="button" class="btn btn-danger btn-sm" data-bind="click:removeSignageRow">
                        <i class="fas fa-trash"></i> Elimina
                    </button>
                </div>
                <div class="col-4 text-end">
                    <i class="fas fa-align-left text-md mx-2 selected-text-align-not" style="cursor: pointer" data-value="left" data-bind="click:setTextAlign"></i>
                    <i class="fas fa-align-center text-md mx-2 selected-text-align-not" style="cursor: pointer" data-value="center" data-bind="click:setTextAlign"></i>
                    <i class="fas fa-align-right text-md mx-2 selected-text-align-not" style="cursor: pointer" data-value="right" data-bind="click:setTextAlign"></i>
                </div>
            </div>
            <div class="mb-3 row">
                <div class="col-10">
                    <input id="##: uid ##_contentInput" type="text" class="form-control" 
                           placeholder="Inserisci qui il contenuto della riga"
                           data-bind="value: content, events: { keyup: updateCharCounter }"
                           data-uid="##: uid ##">
                </div>
                <div class="col-2">
                    <span id="##: uid ##_charCounter" data-uid="##: uid ##"></span>
                </div>
            </div>
        </div>
    </nmscript>
</cfoutput>