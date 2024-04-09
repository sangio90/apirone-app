<cfoutput>

<div class="row" id="company-detail">
    <div class="col-lg-12">
        
        <form id="company-detail-form" action="/manager/company/save" class="form-horizontal" method="POST">
            
            <section class="card">
                
                <header class="card-header">
                    <h2 class="card-title">#prc.title#</h2>
                </header>
                
                <div class="card-body">

                    <div class="form-group row pb-3">
                        <label class="col-sm-3 control-label text-sm-end pt-2">
                            Rapporti <span class="required">*</span>
                        </label>
                        <div class="col-sm-9">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" value="C" id="type_C" name="type"
                                    data-rule-required="true"
                                    data-msg-required="Seleziona almeno un rapporto"
                                >
                                <label class="form-check-label" for="type_C">
                                    Cliente
                                </label>
                              </div>
                              <div class="form-check">
                                <input class="form-check-input" type="checkbox" value="P" id="type_P" name="type">
                                <label class="form-check-label" for="type_P">
                                    Partner
                                </label>
                            </div>
                            <div id="type-error">
                            </div>
                        </div>
                    </div>

                    <div class="form-group row pb-3">
                        <label class="col-sm-3 control-label text-sm-end pt-2">
                            Ragione sociale <span class="required">*</span>
                        </label>
                        <div class="col-sm-9">
                            <input type="text" name="fullname" class="form-control"
                                data-rule-required="true"
                                data-msg-required="Ragione sociale richiesta"
                            />
                        </div>
                    </div>
                    
                    <div class="form-group row pb-3">
                        <label class="col-sm-3 control-label text-sm-end pt-2">
                            Email <span class="required">*</span>
                        </label>
                        <div class="col-sm-9">
                            <div class="input-group">
                                <span class="input-group-text">
                                    <i class="fas fa-envelope"></i>
                                </span>
                                <input type="email" name="email" class="form-control" placeholder="eg.: email@email.com" 
                                    data-rule-required="true"
                                    data-rule-email="true"
                                    data-msg-email="Richiesta una email valida"
                                >
                            </div>
                        </div>
                        <div class="col-sm-9">

                        </div>
                    </div>
                    
                    <div class="form-group row pb-3">
                        <label class="col-sm-3 control-label text-sm-end pt-2">Telefono</label>
                        <div class="col-sm-9">
                            <input type="text" name="phone" class="form-control" placeholder="" />
                        </div>
                    </div>
                    
                    <div class="form-group row pb-3">
                        <label class="col-sm-3 control-label text-sm-end pt-2">Partita Iva</label>
                        <div class="col-sm-9">
                            <input type="text" name="vat" maxlength="11" value="#prc.company.getVAT()#" class="form-control" placeholder="" />
                        </div>
                    </div>
                    
                    <div class="form-group row pb-3">
                        <label class="col-sm-3 control-label text-sm-end pt-2">Persona di riferimento</label>
                        <div class="col-sm-9">
                            <input type="text" name="contact" class="form-control" placeholder="" />
                        </div>
                    </div>
                    
                    <div class="form-group row pb-3">

                        <label class="col-sm-3 control-label text-sm-end pt-2">Commissioni</label>
                        <div class="col-sm-9">

                            <cfloop array="#prc.categories.getData()#" index="item">
                                <div class="row">
                                    <div class="col-md-2 py-2">
                                        <label class="form-check-label" for="comm_#item.getId()#">
                                            #item.getName()#
                                        </label>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="input-group py-1">
                                            <input name="comm_#item.getId()#" id="comm_#item.getId()#" type="text" class="form-control"
                                                data-rule-number="true"
                                                data-msg-number="E' richiesto un valore numerico"
                                            >
                                            <span class="input-group-text" tabindex="-1">
                                                <i class="fa-solid fa-percent"></i>
                                            </span>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div id="comm_#item.getId()#-error" class="pt-2">
                                        </div>
                                    </div>
                                </div>
                            </cfloop>
                        </div>

                    </div>
                
                </div>

                <footer class="card-footer">
                    <div class="row justify-content-end">
                        <div class="col-sm-9">
                            <button class="btn btn-primary">Salva &raquo;</button>
                            <input type="hidden" name="id" value="" >
                        </div>
                    </div>
                </footer>

            </section>
        
        </form>
    
    </div>

</div>

</cfoutput>