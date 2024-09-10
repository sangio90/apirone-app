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
                            <i class="bx bx-user-circle me-1 text-6 position-relative top-5"></i> Pincode
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
                        <p>Inserisci il pincode inviato al numero +39 *** *****47</p>
                        <div class="row">
                            <cfloop from="1" to="6" index="index">
                                <div class="col-2">
                                    <input name="p#index#" id="p#index#" type="text" class="form-control form-control-lg text-center" value="" maxlength="1" />
                                </div>
                            </cfloop>
                        </div>
                        
                        <div id="login-error"></div>
                    </div>

                    <div class="row">
                        <div class="col-sm-12">
                            <div class="checkbox-custom checkbox-default">
                                <input id="RememberMe" name="rememberme" type="checkbox"/>
                                <label for="RememberMe">Ricorda questo device per 30 giorni</label>
                            </div>
                        </div>
                        <div class="col-sm-12 text-end">
                            <button type="submit" class="btn btn-primary mt-2">Verifica &raquo;</button>
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