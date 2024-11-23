<cfoutput>
    <div id="my-account-root">

        #pageTitle()#

        <div class="col-12">
            
            <section class="card">

                <div class="card-body">
                    
                    <div class="row gx-5">

                        <div class="col-lg-6">
                            
                            <div class="row">

                                <div class="col-lg-12">
                                    <h3>Dettagli</h3>
                                </div>

                                <hr class="mt-3">
                                
                                <div class="col-3 text-end">
                                    <b>ID:</b>
                                </div>
                                <div class="col-9">
                                    #prc.user.getAccount().getShortId()#
                                </div>

                                <hr class="mt-3">

                                <div class="col-3 text-end">
                                    <b>Email:</b>
                                </div>
                                <div class="col-9">
                                    #prc.user.getAccount().getName()#
                                </div>

                                <hr class="mt-3">

                                <div class="col-3 text-end">
                                    <b>Email:</b>
                                </div>
                                <div class="col-9">
                                    #prc.user.getAccount().getEmail()#
                                </div>

                                <hr class="mt-3">

                                <div class="col-3 text-end">
                                    <b>Lingua:</b>
                                </div>
                                <div class="col-9">
                                    #prc.user.getAccount().getLang().getName()#
                                </div>

                                <hr class="mt-3">

                            </div>

                        </div>

                        <div class="col-lg-6">

                            <form id="my-account-detail-form">

                            <div class="row">

                                <div class="col-lg-12">
                                    <h3>Modifica la password</h3>
                                </div>

                                <hr class="mt-3">
                                
                                <div class="col-12">
                                    <div class="form-group pb-3">
                                        <label class="col-form-label" for="option-desc">Password</label>
                                        <input type="password" class="form-control" name="pwd" 
                                            maxlength="20"
                                            data-rule-required="true"
                                            data-msg-required="Password richiesta"
                                            data-rule-equalTo="##pwd2"
                                            data-msg-equalTo="Le password non coincidono"
                                            data-rule-pwdRule="true"
                                        >
                                    </div>
                                </div>
                                
                                <div class="col-12">
                                    <div class="form-group pb-3">
                                        <label class="col-form-label" for="option-desc">Conferma password</label>
                                        <input type="password" class="form-control" name="pwd2" id="pwd2"
                                            maxlength="20"
                                            data-rule-required="true"
                                            data-msg-required="La password di conferma è richiesta"
                                        >
                                    </div>
                                </div>
                                
                                <div class="col-12 mt-3">
                                    #saveButton( label="Modifica password", size="md") #
                                </div>
                                

                            </div>

                            </form>

                        </div>
                    </div>
                </div>                                
                
            </section>
            
        </div>
        
    </div>

</cfoutput>