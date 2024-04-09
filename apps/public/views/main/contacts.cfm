<cfset add1 = RandRange(1, 5)>
<cfset add2 = RandRange(1, 5)>

<cfoutput>

    <section class="border-0 pt-5 m-0 pb-3">
        <div class="container">
            <div class="row align-items-end pb-3 mb-5 mb-lg-4">
                <div class="col-lg-7 col-xl-8 mb-4 mb-lg-0">
                    <h3 class="text-color-secondary font-weight-bold text-transform-none text-8 mb-3 pb-1">
                        Contattaci
                    </h3>
                    <p class="mb-0">
                        Sentiti libero di chiedere ciò che vuoi. Ti risponderemo al più presto.
                    </p>
                </div>
            </div>
        </div>
    </section>


    <div class="container">

        <div class="row py-4">
            <div class="col-lg-6">

                <form class="contact-form" action="/public/ajax/send-message" method="POST">
                    <div class="contact-form-success alert alert-success d-none mt-4">
                        <strong>Success!</strong> Your message has been sent to us.
                    </div>

                    <div class="contact-form-error alert alert-danger d-none mt-4">
                        <strong>Error!</strong> There was an error sending your message.
                        <span class="mail-error-message text-1 d-block"></span>
                    </div>

                    <div class="row">
                        <div class="form-group col">
                            <label class="form-label mb-1 text-2">Nome</label>
                            <input type="text" value="" data-msg-required="Nome obbligatorio." maxlength="100" class="form-control text-3 h-auto py-2" name="name" required>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group col">
                            <label class="form-label mb-1 text-2">Email</label>
                            <input type="email" value="" data-msg-required="Email obbligatoria." data-msg-email="Email non valida." maxlength="100" class="form-control text-3 h-auto py-2" name="email" required>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group col">
                            <label class="form-label mb-1 text-2">Messaggio</label>
                            <textarea maxlength="5000" data-msg-required="Inserisci il messaggio." rows="8" class="form-control text-3 h-auto py-2" name="message" required></textarea>
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group col">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" value="" id="acceptPrivacy" name="acceptPrivacy">
                                <label class="form-check-label" for="acceptPrivacy">
                                    Acconsento alla vostra informativa sulla <a href="/public/privacy">privacy</a>.
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-1">
                            <input class="form-check-input" type="text" value="" id="add1" name="add1">
                        </div>
                        <div class="col-1">
                            <input class="form-check-input" type="text" value="" id="add2" name="add2">
                        </div>
                    </div>
                    <div class="row">
                        <div class="form-group col">
                            <input type="submit" value="Invia >" class="btn btn-primary btn-modern" data-loading-text="Sto inviando...">
                        </div>
                    </div>
                </form>

            </div>
            <div class="col-lg-6">
                <div>
                    <h4 class="mt-2 mb-1"><strong>Riferimenti</strong></h4>
                    <ul class="list list-icons list-icons-style-2 mt-2">
                        <li><i class="fas fa-map-marker-alt top-6"></i> #event.getValue('config').get('owner.name')#</li>
                        <li><i class="fas fa-map-marker-alt top-6"></i> <strong class="text-dark">Partita Iva:</strong> #event.getValue('config').get('owner.vat')#</li>
                        <li><i class="fas fa-envelope top-6"></i> <strong class="text-dark">Email:</strong> <a href="#event.getValue('config').get('owner.email')#">#event.getValue('config').get('owner.email')#</a></li>
                    </ul>
                </div>

                <h4 class="pt-5">Rimaniamo in <strong>contatto</strong></h4>
                <p class="lead mb-0 text-4">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur eget leo at velit imperdiet varius. In eu ipsum vitae velit congue iaculis vitae at risus. Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>

            </div>

        </div>

    </div>    

</cfoutput>
