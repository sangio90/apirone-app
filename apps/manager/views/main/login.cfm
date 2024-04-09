<cfparam name="msg" default="">

<cfoutput>

<div class="center-sign">

    <div class="center-sign">

        <div class="panel card-sign">

            <div class="card-title-sign mt-3">
                <div class="row">
                    <div class="col-6 mb-2">
                        <img src="/assets/main/img/logo.png" height="70" alt="Zerobenefit" />
                    </div>
                    <div class="col-6 text-end mt-5">
                        <h2 class="title text-uppercase font-weight-bold m-0" >
                            <i class="bx bx-user-circle me-1 text-6 position-relative top-5"></i> Entra
                        </h2>
                    </div>
                </div>
            </div>

            <div class="card-body">

                <form action="/manager/login/do" method="POST" id="login-form" autocomplete="true">

                    <cfif flash.exists('message')>
                        <div class="alert alert-danger alert-dismissible fade show">
                            #flash.get('message')#
                        </div>
                    </cfif>
                    
                    <div class="form-group mb-3">
                        <label>Nome utente</label>
                        <div class="input-group">
                            <input name="login" id="login" type="text" class="form-control form-control-lg" />
                            <span class="input-group-text">
                                <i class="bx bx-user text-4"></i>
                            </span>
                        </div>
                        <div id="login-error"></div>
                    </div>

                    <div class="form-group mb-3">
                        <div class="clearfix">
                            <label class="float-left">Password</label>
                            <a href="/manager/recover-password" class="float-end">Password smarrita?</a>
                        </div>
                        <div class="input-group">
                            <input name="pwd" id="pwd" type="password" class="form-control form-control-lg" />
                            <span class="input-group-text">
                                <i class="bx bx-lock text-4"></i>
                            </span>
                        </div>
                        <div id="pwd-error"></div>
                    </div>

                    <div class="row">
                        <div class="col-sm-8">
                            <div class="checkbox-custom checkbox-default">
                                <input id="RememberMe" name="rememberme" type="checkbox"/>
                                <label for="RememberMe">Ricordami</label>
                            </div>
                        </div>
                        <div class="col-sm-4 text-end">
                            <button type="submit" class="btn btn-primary mt-2">Entra &raquo;</button>
                        </div>
                    </div>

                    <!----
                    <span class="mt-3 mb-3 line-thru text-center text-uppercase">
                        <span>or</span>
                    </span>

                    <p class="text-center">Don't have an account yet? <a href="pages-signup.html">Sign Up!</a></p>
                    ------->

                </form>
            </div>
        </div>

        <p class="text-center text-muted mt-3 mb-3">
            &copy; Copyright 2022-#Year(now())#. Tutti i diritti riservati.
            <br> #prc.config.appName# v.#prc.config.appVersion#
        </p>
    </div>    

</cfoutput>