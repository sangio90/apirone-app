<cfoutput>

    <div id="quotation-detail">


        <div class="row mb-3">
            <div class="col-lg-8">
                <h2>#prc.title#</h2>
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
                                    <button class="nav-link" id="nav-print-tab" data-bs-toggle="tab" data-bs-target="##nav-print" type="button" role="tab">Stampa</button>
                                    <button class="nav-link" id="nav-discount-tab" data-bs-toggle="tab" data-bs-target="##nav-discount" type="button" role="tab">Sconti/Costi</button>
                                    <button class="nav-link" id="nav-billing-tab" data-bs-toggle="tab" data-bs-target="##nav-billing" type="button" role="tab">Fatturazione</button>
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
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Nome</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Lingua</label>
                                        <div class="col-sm-9">
                                            <select name="statusId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <option value="ACP">Italiano</option>
                                                <option value="CRE">Inglese</option>
                                                <option value="REF">Francese</option>
                                                <option value="REF">Tedesco</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Data documento</label>
                                        <div class="col-sm-9">
                                            <input type="date" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Data validità</label>
                                        <div class="col-sm-9">
                                            <input type="date" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Stato</label>
                                        <div class="col-sm-9">
                                            <select name="statusId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <option value="ACP">Italiano</option>
                                                <option value="CRE">Inglese</option>
                                                <option value="REF">Francese</option>
                                                <option value="REF">Tedesco</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Nome opportunità</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Nome lead</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Note</label>
                                        <div class="col-sm-9">
                                            <textarea name="note" class="form-control" rows="8"></textarea>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <div class="col-sm-9 offset-sm-3 float-end">
                                           <button class="btn btn-primary">Successivo &raquo;</button>
                                        </div>
                                    </div>

                                </div>
                                

                                <!---
                                    dati fiscali 
                                --->
                                <div class="tab-pane fade" id="nav-fiscal" role="tabpanel">
                                    
                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Nome</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Listino</label>
                                        <div class="col-sm-9">
                                            <select name="statusId" class="form-control">
                                                <option value="">-- selezionare</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Pagamento</label>
                                        <div class="col-sm-9">
                                            <select name="statusId" class="form-control">
                                                <option value="">-- selezionare</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Pagamento personalizzato</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="str" class="form-control">
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Aliquota IVA</label>
                                        <div class="col-sm-9">
                                            <select name="statusId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <cfloop array="#prc.vatCodeList#" item="item">
                                                    <option value="#item.getId()#">#item.getName()# (#item.getValue()#%)</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group row mb-2">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Valuta</label>
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

                                </div>

                                <!---
                                    shipment
                                --->
                                <div class="tab-pane fade" id="nav-shipment" role="tabpanel">

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

                                </div>



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
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Tecnico / grafico</label>
                                        <div class="col-sm-9">
                                            <select name="statusId" class="form-control">
                                                <option value="">-- selezionare</option>
                                                <cfloop array="#prc.vatCodeList#" item="item">
                                                    <option value="#item.getId()#">#item.getName()# (#item.getValue()#%)</option>
                                                </cfloop>
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