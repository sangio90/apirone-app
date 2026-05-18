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
                        <h2 class="title text-uppercase font-weight-bold m-0">
                            <i class="bx bx-lock-open me-1 text-6 position-relative top-5"></i> Nuova password
                        </h2>
                    </div>
                </div>
            </div>

            <div class="card-body">

                <form action="/manager/login/reset-password/check" method="POST" id="reset-password-form" autocomplete="off">

                    <cfif flash.exists('message')>
                        <cfset flashMsg = flash.get('message')>
                        <div class="alert alert-#flashMsg.type# alert-dismissible fade show">
                            #flashMsg.message#
                        </div>
                    </cfif>

                    <input type="hidden" name="token" value="#encodeForHTMLAttribute(rc.token)#" />

                    <div class="form-group mb-3">
                        <label>Nuova password</label>
                        <input name="pwd" id="pwd" type="password" class="form-control form-control-lg" required />
                    </div>

                    <div class="form-group mb-3">
                        <label>Conferma password</label>
                        <input name="pwd2" id="pwd2" type="password" class="form-control form-control-lg" required />
                    </div>

                    <div class="row">
                        <div class="col-sm-4 mt-2">
                            <p><a href="/manager/login">Torna al login</a></p>
                        </div>
                        <div class="col-sm-8 text-end">
                            <button type="submit" class="btn btn-primary mt-2">Salva password &raquo;</button>
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

</div>

</cfoutput>
