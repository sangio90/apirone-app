<cfparam name="msg" default="">

<cfoutput>

<div class="center-sign">

    <div class="center-sign">

        <div class="panel card-sign">

            <div class="card-title-sign mt-3">
                <div class="row">
                    <div class="col-6 mb-2">
                        <img src="/assets/main/img/logo.png" height="70" alt="Apir" />
                    </div>
                    <div class="col-6 text-end mt-5">
                        <h2 class="title text-uppercase font-weight-bold m-0" >
                            <i class="bx bx-user-circle me-1 text-6 position-relative top-5"></i> Recupera password
                        </h2>
                    </div>
                </div>
            </div>

            <div class="card-body">

                <form action="/manager/login/pincode/check" method="POST" id="pincode-form" autocomplete="true">

                    <cfif flash.exists('message')>
                        <div class="alert alert-danger alert-dismissible fade show">
                            #flash.get('message')#
                        </div>
                    </cfif>
                    
                    <div class="form-group mb-3">
                        <p>Inserisci la tua email o il tuo numero di telefono:</p>
                        <div class="row">
                            <div class="col-12">
                                <input name="reference" id="reference" type="text" class="form-control form-control-lg" placeholder="Numero di telefono o email" value="" />
                            </div>
                        </div>
                        
                        <div id="login-error"></div>
                    </div>

                    <div class="row">
                        <div class="col-sm-12 mb-3">
                            Ti verrà inviato un link via email da cui azzerare la password.
                        </div>
                        <div class="col-sm-4 mt-2">
                            <p><a href="/manager/login">Torna al login</a></p>
                        </div>
                        <div class="col-sm-8 text-end">
                            <button type="submit" class="btn btn-primary mt-2">Invia link &raquo;</button>
                        </div>
                    </div>

                </form>
            </div>
        </div>

        <p class="text-center text-muted mt-3 mb-3">
            &copy; Copyright 2022-#Year(now())#. Tutti i diritti riservati.
            <br> #prc.config.appName# v.#prc.config.appVersion#
        </p>
    </div>    

</cfoutput>