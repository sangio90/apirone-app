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
                            <i class="bx bx-user-circle me-1 text-6 position-relative top-5"></i> Entra
                        </h2>
                    </div>
                </div>
            </div>

            <div class="card-body">

                <form action="/manager/login/check" method="POST" id="login-form" autocomplete="true">

                    <cfif flash.exists("message")>
                        <div class="alert alert-danger alert-dismissible fade show">
                            #flash.get("message")#
                        </div>
                    </cfif>
                    
                    <div class="form-group mb-3">
                        <label>Nome utente</label>
                        <div class="input-group">
                            <input name="email" id="email" type="text" class="form-control form-control-lg" value="#rc.email#" />
                            <span class="input-group-text">
                                <i class="bx bx-user text-4"></i>
                            </span>
                        </div>
                        <div id="login-error"></div>
                    </div>

                    <div class="form-group mb-3">
                        <div class="clearfix">
                            <label class="float-left">Password</label>
                            <a href="/manager/login/recover" class="float-end">Password smarrita?</a>
                        </div>
                        <div class="input-group">
                            <input name="pwd" id="pwd" type="password" class="form-control form-control-lg">
                            <span class="input-group-text">
                                <i class="bx bx-lock text-4"></i>
                            </span>
                        </div>
                        <div class="row">
                            <div class="col-sm-6">
                                <div id="pwd-error" class="field-error-message"></div>
                            </div>
                            <div class="col-sm-6 text-end">
                                <a href="javascript:;" onclick="AP.login.togglePwd()" class="float-end" tabindex="-1" id="label-change-type">Mostra password</a>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-sm-8">
                        </div>
                        <div class="col-sm-4 text-end">
                            <button type="submit" class="btn btn-primary mt-2">Login &raquo;</button>
                        </div>
                    </div>

                </form>
            </div>
        </div>

        <p class="text-center text-muted mt-3 mb-3">
            &copy; Copyright 2023-#Year(now())#. Tutti i diritti riservati.
            <br> #prc.config.appName# v.#prc.config.appVersion#
        </p>
    </div>    

</cfoutput>