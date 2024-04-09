<cfoutput>

    <cfset breadcrumbs = [ 
        { id = 'home', name="Home", url="/public/home" },
        { id = 'card', name="Tessera", url="" }
    ]>

    <cfmodule template="/apps/utils/ctags/titleSection.cfm" 
        title="Tessera"
        breadcrumbs="#breadcrumbs#"
    >

    <div class="container py-5 mt-5">

        <cfif flash.get( "showFiscalCodeForm", true )>

            <div class="row pb-2 mb-4">
                <div class="col">
                    <div class="d-flex align-items-center mb-2">
                        <span class="custom-line"></span>
                        <div class="overflow-hidden ms-3">
                            <h2 class="text-color-primary font-weight-semibold line-height-3 text-4 mb-0">
                                RITIRA LA TUA TESSERA
                            </h2>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row pb-5">
                <div class="col">

                    <form class="custom-form-style-1" id="fiscalCodeForm" action="/public/employee/check-fiscalcode" method="POST">
        
                        <div class="row row-gutter-sm">
                            <div class="form-group col-lg-6 mb-4">
                                <label class="form-label mb-0 text-2">
                                    Inserisci il codice della tessera
                                </label>
                                <input type="text" maxlength="17" class="form-control" name="fiscalCode" id="fiscalCode" required 
                                    data-msg-required="Inserisci il tuo codice fiscale" 
                                    placeholder="Codice fiscale"
                                >
                            </div>
                            <div class="form-group col-lg-6 mb-4 mt-4" style="padding-top:3px">
                                <button type="submit" class="btn btn-primary btn-modern font-weight-bold text-3 px-5 py-3">CONTROLLA</button>
                            </div>
                        </div>
        
                    </form>
                </div>
            </div>
        
        </cfif>

    </div>

</div>



</cfoutput>
