<cfoutput>

    <cfset breadcrumbs = [ 
        { id = 'home', name="Home", url="/public/home" },
        { id = 'subscription', name="Iscrizione", url="/public/employee/subscribe" }
    ]>

    <cfmodule template="/apps/utils/ctags/titleSection.cfm" 
        title="Iscrizione"
        breadcrumbs="#breadcrumbs#"
    >

    <div class="container py-5 mt-5">

        <div class="row pb-2 mb-4">
            <div class="col">
                <div class="d-flex align-items-center mb-2">
                    <span class="custom-line"></span>
                    <div class="overflow-hidden ms-3">
                        <h2 class="text-color-primary font-weight-semibold line-height-3 text-4 mb-0">
                            NON SEI REGISTRATO
                        </h2>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row pb-2 mb-4">
            <div class="col">
                <h3 class="text-color-secondary font-weight-bold text-transform-none line-height-2 text-8 mb-0">
                    INSERISCI I TUOI DATI
                </h3>
            </div>
        </div>

        <div class="row pb-5">
            <div class="col">
                <form class="contact-form custom-form-style-1" action="/public/employee/create" method="POST">

                    <div class="row row-gutter-sm">
                        <div class="form-group col-lg-6 mb-4">
                            <input type="text" value="" maxlength="100" class="form-control" 
                                required 
                                name="name" id="name" 
                                data-msg-required="Inserisci il tuo nome" 
                                placeholder="Il tuo nome"
                            >
                        </div>

                        <div class="form-group col-lg-6 mb-4">
                            <input type="text" value="" maxlength="100" class="form-control" 
                                required 
                                name="surname" id="surname" 
                                data-msg-required="Inserisci il tuo cognome." 
                                placeholder="Il tuo cognome"
                            >
                        </div>
                    </div>
                    <div class="row row-gutter-sm">
                        <div class="form-group col-lg-6 mb-4">
                            <!--- TODO: check email exists --->
                            <input type="email" value="" maxlength="100" class="form-control" 
                                required
                                name="email" id="email" 
                                data-msg-required="Inserisci la tua email" 
                                data-msg-email="Inserisci una email valida"  
                                placeholder="La tua email"
                            >
                        </div>

                        <div class="form-group col-lg-6 mb-4">
                            <input type="text" value="" maxlength="100" class="form-control" 
                                required
                                name="fiscalCode" id="fiscalCode" 
                                maxlength="16"
                                data-msg-required="Inserisci il tuo codice fiscale" 
                                data-msg-maxlength="Al massimo 16 caratteri" 
                                data-rule-maxlength="16" 
                                placeholder="Il tuo codice fiscale"
                            >
                        </div>
                    </div>
                    
                    <div class="row row-gutter-sm">
                        <div class="form-group col-lg-6 mb-4">
                            <!--- TODO: check phone exists (for double auth) --->
                            <input type="text" value="" maxlength="100" class="form-control" 
                                required
                                name="phone" 
                                id="phone" 
                                data-msg-required="Inserisci il tuo telefono" 
                                placeholder="Il tuo telefono"
                            >
                        </div>
                    </div>

                    <div class="row row-gutter-sm">
                        <div class="form-group col-lg-6 mb-4">
                            <!--- TODO: check email exists --->
                            <input type="text" value="" maxlength="100" class="form-control" 
                                required
                                name="pwd" id="pwd" 
                                maxlength="20"
                                data-rule-minlength="8"
                                data-msg-required="Inserisci la tua password" 
                                data-msg-minlength="Almeno 8 caratteri" 
                                placeholder="Scegli la tua password"
                            >
                        </div>
                        <div class="form-group col-lg-6 mb-4">
                            <input type="text" value="" maxlength="100" class="form-control" 
                                required
                                name="pwd2" id="pwd2" 
                                data-msg-required="Conferma la tua password" 
                                data-msg-equalTo="Le password non coincidono" 
                                data-rule-equalTo="##pwd" 
                                placeholder="Conferma la tua password"
                            >
                        </div>
                    </div>                        

                    <div class="row">
                        <div class="form-group col mb-0">
                            <button type="submit" class="btn btn-primary btn-modern font-weight-bold text-3 px-5 py-3">ISCRIVIMI ></button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    
    </div>

</div>



</cfoutput>
