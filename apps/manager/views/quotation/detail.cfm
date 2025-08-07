<cfoutput>

    <div id="quotation-detail-root">


        <div class="row mb-3">
            <div class="col-lg-6">
                <h2>#prc.title#</h2>
            </div>
			<div class="col-6 text-end">
				#button( bind = "click:list", size = "md", label = "Torna ai preventivi" )#
			</div>
        </div>

        <div class="row">
            <div class="col-lg-12">
                
                <form action="/manager/quotations" class="form-horizontal" method="post" id="quotation-detail-form">
                    
                    <section class="card">
                        
                        <div class="card-body">

                            <nav>
                                <div class="nav nav-tabs" id="nav-tab" role="tablist">
                                    <button class="nav-link active" id="nav-general-tab" data-bs-toggle="tab" data-bs-target="##nav-general" type="button" role="tab">Dati generali</button>
                                    <button class="nav-link" id="nav-fiscal-tab" data-bs-toggle="tab" data-bs-target="##nav-fiscal" type="button" role="tab">Dati fiscali</button>
                                    <button class="nav-link" id="nav-billing-tab" data-bs-toggle="tab" data-bs-target="##nav-billing" type="button" role="tab">Fatturazione</button>
                                    <button class="nav-link" id="nav-print-tab" data-bs-toggle="tab" data-bs-target="##nav-print" type="button" role="tab">Stampa</button>
                                    <button class="nav-link" id="nav-discount-tab" data-bs-toggle="tab" data-bs-target="##nav-discount" type="button" role="tab">Sconti/Costi</button>
                                    <button class="nav-link" id="nav-shipment-tab" data-bs-toggle="tab" data-bs-target="##nav-shipment" type="button" role="tab">Spedizione</button>
                                    <button class="nav-link" id="nav-assignment-tab" data-bs-toggle="tab" data-bs-target="##nav-assignment" type="button" role="tab">Assegnatario</button>
                                </div>
                            </nav>
                            <div class="tab-content" id="nav-tabContent">
                                
                                <!--- 
                                    general 
                                --->
                                <div class="tab-pane fade show active" id="nav-general" role="tabpanel">

                                    <div class="form-group row mb-2">
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end">Nome <span class="required">*</span></label>
                                            <input type="text" name="description" class="form-control" id="description"
                                                data-rule-required="true"
                                                data-msg-required="Nome"
                                            >
                                        </div>
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end">Lingua <span class="required">*</span></label>
                                            <select name="langId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <cfloop array="#prc.langs#" item="item">
                                                    <option value="#item.getId()#">#item.getName()#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end">Data documento</label>
                                            <input type="text" class="form-control" value="#DateFormat( now(), 'dd/mm/yyyy' )#" disabled>
                                        </div>
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end">Data validità <span class="required">*</span></label>
                                            <input type="text" name="validity_date" class="form-control" value="#DateFormat( DateAdd( 'm', 1, now() ), 'dd/mm/yyyy' )#">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <div class="col-sm-9">
                                            <label class="control-label text-sm-end">Note</label>
                                            <textarea name="note" class="form-control" rows="1"></textarea>
                                        </div>
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end">Stato <span class="required">*</span></label>
                                            <select name="statusId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <cfloop array="#prc.statusList#" item="item">
                                                    <option value="#item.getId()#">#item.getName()#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <div class="col-sm-5">
                                            <label class="control-label text-sm-end">Nome opportunità <span class="required">*</span></label>
                                            <input type="text" name="opportunity_name" class="form-control">
                                        </div>
                                        <div class="col-sm-5">
                                            <label class="control-label text-sm-end">Nome lead <span class="required">*</span></label>
                                            <input type="text" name="lead_name" class="form-control">
                                        </div>
                                        <div class="col-sm-2 pt-4">
                                           <button class="btn btn-primary changeTab" id="fiscal">Dati fiscali &raquo;</button>
                                        </div>
                                    </div>

                                </div>
                                

                                <!---
                                    dati fiscali 
                                --->
                                <div class="tab-pane fade" id="nav-fiscal" role="tabpanel">
                                    <div class="form-group row mb-2">
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end pt-2">Listino <span class="required">*</span></label>
                                            <select name="pricelistId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <cfloop array="#prc.pricelist#" item="item">
                                                    <option value="#item.getId()#">#item.getName()#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end pt-2">Pagamento</label>
                                            <select name="paymentMethodId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <cfloop array="#prc.paymentMethod#" item="item">
                                                    <option value="#item.getId()#">#item.getName()#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                        <div class="col-sm-3 pt-2">
                                            <label class="control-label text-sm-end pb-2">Pagamento personalizzato</label>
                                            <input type="text" name="custom_payment_method" class="form-control" id="custom_payment_method">
                                        </div>
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end pt-2">Aliquota IVA</label>
                                            <select name="vatCodeId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <option value="A">Iva A</option>
                                                <option value="B">Iva B</option>
                                                <option value="C">Iva C</option>
                                                <option value="D">Iva D</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <div class="col-sm-3">
                                            <label class="control-label text-sm-end">Valuta</label>
                                            <select name="currencyId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <cfloop array="#prc.currency#" item="item">
                                                    <option value="#item.getId()#">#item.getName()#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                        <div class="col-sm-3 pt-4">

                                           <button class="btn btn-default changeTab" id="general">&laquo; Precedente &raquo;</button>
                                            <button class="btn btn-primary changeTab" id="billing">Fatturazione &raquo;</button>
                                        </div>
                                    </div>

                                </div>

                                <!---
                                    billing
                                --->
                                <div class="tab-pane fade" id="nav-billing" role="tabpanel">

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Nome</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Ragione sociale</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Partita Iva</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Email</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Telefono</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Indirizzo</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Città</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">CAP</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Nazione</label>
                                        <div class="col-sm-9">
                                            <select name="statusId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <cfloop array="#prc.statusList#" item="item">
                                                    <option value="#item.getId()#">#item.getName()#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Provincia</label>
                                        <div class="col-sm-9">
                                            <select name="statusId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <option value="REF">22%</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <div class="col-sm-9 offset-sm-3">

                                            <button class="btn btn-default">&laquo; Precedente &raquo;</button>
                                            <button class="btn btn-primary">Successivo &raquo;</button>

                                        </div>
                                    </div>                                    

                                </div>                                
                
                                <!---
                                    print
                                --->
                                <div class="tab-pane fade" id="nav-print" role="tabpanel">
                                    <p>print</p>
                                </div>
                            
                                <!---
                                    cost / discount
                                --->
                                <div class="tab-pane fade" id="nav-discount" role="tabpanel">
                                    <p>price / discount</p>
                                </div>
                            
                                <!---
                                    shipment
                                --->
                                <div class="tab-pane fade" id="nav-shipment" role="tabpanel">

                                </div>


                                    <!-----------
                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Nome</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Ragione sociale</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Indirizzo</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Città</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">CAP</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Nazione</label>
                                        <div class="col-sm-9">
                                            <select name="statusId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <option value="REF">22%</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Provincia</label>
                                        <div class="col-sm-9">
                                            <select name="statusId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <option value="REF">22%</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <div class="col-sm-9 offset-sm-3">

                                            <button class="btn btn-default">&laquo; Precedente &raquo;</button>
                                            <button class="btn btn-primary">Successivo &raquo;</button>

                                        </div>
                                    </div>
                                    ----->


                                <!---
                                    assignment
                                --->
                                <div class="tab-pane fade" id="nav-assignment" role="tabpanel">

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Commerciale</label>
                                        <div class="col-sm-9">
                                            <select name="statusId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <option value="REF">22%</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <div class="col-sm-9 offset-sm-3">

                                            <button class="btn btn-default">&laquo; Precedente &raquo;</button>
                                            <button class="btn btn-primary"><i class="fa fa-save"></i> Salva</button>

                                        </div>
                                    </div>                                    

                                </div>                                

                            
                            </div>                         
                            
                    </section>
                
                </form>
            
            </div>

        </div>

    </div>

</cfoutput>
<script>
document.addEventListener("DOMContentLoaded", function () {
    // Cerca tutti i bottoni con classe `changeTab`
    document.querySelectorAll("button.changeTab").forEach(function (button) {
        button.addEventListener("click", function (e) {
            e.preventDefault();

            // Recupera l'id del bottone, es: "fiscal"
            const targetName = this.id;

            // Costruisce l'id del tab corrispondente
            const targetTabId = `nav-${targetName}-tab`;

            // Trova il pulsante di tab nella barra
            const tabTrigger = document.getElementById(targetTabId);

            if (tabTrigger) {
                const tab = new bootstrap.Tab(tabTrigger);
                tab.show();
            } else {
                console.warn(`Nessun tab trovato con id ${targetTabId}`);
            }
        });
    });
});
</script>
