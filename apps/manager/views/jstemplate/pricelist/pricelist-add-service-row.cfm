<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="pricelist-add-service-row-tmpl">

        <div class="col-12">

            <div class="row mt-4">

                <div class="col-6">
                    <label class="mt-1">Servizio <b>##=name##:</b></label>
                </div>

                <div class="col-3">
                    <label class="mt-1">Prezzo:</label>
                </div>
                
                <div class="col-3">
                    <div class="input-group">
                        <input type="text" class="form-control" name="price_##=id##" id="price_##=id##"
                            data-bind="value: price"
                            data-rule-required="true"
                            data-msg-required="Campo richiesto"
                            data-rule-number="true" 
                            data-msg-number="Richiesto valore decimale"
                        >
                        <span class="input-group-text">
                            <i class="fa-solid fa-euro-sign"></i>
                        </span>
                    </div>
                    <div id="price_##=id##-error"></div>

                </div>

            </div>

        </div>        

    </nmscript>
</cfoutput>

