<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="pricelist-modify-days-row-tmpl">

        <div class="col-12">

            <div class="row mt-4">

                <div class="col-6">
                    <label class="mt-3">Servizio <b>##=name##:</b></label>
                </div>
                <div class="col-2">
                    <label class="mt-3">Giorni</label>
                </div>

                <div class="col-4">
                    <div>
                        <div class="input-group mt-2">
                            <input type="text" class="form-control" name="days_##=id##" id="days_##=id##"
                                data-bind="value: days"
                                data-rule-required="true"
                                data-msg-required="Campo richiesto"
                                data-rule-integer="true" 
                                data-msg-integer="Richiesto valore intero"
                            >
                        </div>
                        <div id="days_##=id##-error"></div>
                    </div>

                </div>

            </div>

        </div>        

    </nmscript>
</cfoutput>
