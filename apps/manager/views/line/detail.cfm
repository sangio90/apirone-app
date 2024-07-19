<cfoutput>

    <div id="line-detail-root">


        <div class="row mb-3">
            <div class="col-lg-8">
                <h2>#prc.title#</h2>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12">
                
                <form action="/manager/products/save" class="form-horizontal" method="post" id="product-detail-form">
                    
                    <section class="card">
                        
                        <div class="card-body">

                            <div class="row">
                                <div class="col-sm-9">

                                    <div class="form-group row pb-3">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Codice</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="code" class="form-control" maxlength="15" placeholder="" value="#prc.obj.getId()#" disabled
                                                onkeyup="this.value=this.value.toUpperCase()" 
                                            />
                                        </div>
                                    </div>
        
                                    <div class="form-group row pb-3">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">Nome</label>
                                        <div class="col-sm-9">
                                            <input type="text" name="code" class="form-control" maxlength="15" placeholder="" value="#prc.obj.getName()#" disabled
                                                onkeyup="this.value=this.value.toUpperCase()" 
                                            />
                                        </div>
                                    </div>
        
                                    <div class="form-group row pb-3">
                                        <label class="col-sm-3 control-label text-sm-end pt-2">
                                            Stato
                                        </label>
                                        <div class="col-sm-9">
                                            <select class="form-control" name="statusId">
                                                <option value="">-- Seleziona</option>
                                                <cfloop array="#prc.statusList#" item="item">
                                                    <option value="#item.id#" SELECTED>#item.name#</option>
                                                </cfloop>
                                            </select>
                                        </div>
                                    </div>
        
                                    <hr>
        
                                    <cfset n = 1>
                                    <cfloop array="#prc.priceLists#" item="item">
        
                                        <div class="form-group row pb-3 ">
                                            <div class="col-sm-3 offset-md-3">
                                                <b>#item.name#</b>
                                            </div>
                                        </div>
                                    
                                        <div class="form-group row pb-3">
                                            <label class="col-sm-3 control-label text-sm-end pt-2">Prezzo</label>
                                            <div class="col-sm-9">
                                                <div class="input-group">
                                                    <input type="number" name="price" class="form-control" placeholder="" value="#item.price#" />
                                                    <span class="input-group-text">
                                                        <i class="fas fa-euro-sign text-4"></i>
                                                    </span>
                                                </div>
                                                <div id="price-error"></div>
                                            </div>
                                        </div>
        
                                        <div class="form-group row pb-3">
                                            <label class="col-sm-3 control-label text-sm-end pt-2">Costo</label>
                                            <div class="col-sm-9">
                                                <div class="input-group">
                                                    <input type="number" name="price" class="form-control" placeholder="" value="#item.cost#" />
                                                    <span class="input-group-text">
                                                        <i class="fas fa-euro-sign text-4"></i>
                                                    </span>
                                                </div>
                                                <div id="price-error"></div>
                                            </div>
                                        </div>                                
                    
                                        <!----
                                        <div class="form-group row pb-3">
                                            <label class="col-sm-3 control-label text-sm-end pt-2">Sconto</label>
                                            <div class="col-sm-9">
                                                <div class="row">
                                                    <div class="col-sm-12">
                                                        <div class="row">
                                                            <div class="col-sm-6">
                                                                <input type="number" name="discountValue" class="form-control" placeholder="Valore" />
                                                            </div>
                                                            <div class="col-sm-6">
                                                                <select name="discountType" class="form-control" >
                                                                    <option value="F">Fisso</option>
                                                                    <option value="P">Percentuale</option>
                                                                </select>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        ---->
        
                                        <cfif n LT prc.pricelists.len()>
                                            <hr>
                                        </cfif>
                                        
                                        <cfset n++>
                                    </cfloop>
        
                                </div>
                                <div class="col-sm-3">

                                    <h3>Spessori</h3>
                                    <cfloop array="#prc.thicknesses#" item="thickness">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" value="#thickness.getId()#" id="thickness_#thickness.getId()#">
                                            <label class="form-check-label" for="thickness_#thickness.getId()#">
                                                #thickness.getName()#
                                            </label>
                                        </div>
                                    </cfloop>

                                    <br>
                                    <br>

                                    <h3>Dimensioni</h3>
                                    <cfloop array="#prc.sizes#" item="size">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" value="#thickness.getId()#" id="size_#size.getId()#">
                                            <label class="form-check-label" for="size_#size.getId()#">
                                                #size.getName()#
                                            </label>
                                        </div>
                                    </cfloop>
                                    
                                </div>

                            </div>
                            

                        </div>


                        <footer class="card-footer py-4">
                            <div class="form-group row">
                                <label class="col-sm-3">.</label>
                                <div class="col-sm-9">
                                    <button class="btn btn-primary">Salva &raquo;</button>
                                </div>
                            </div>
                        </footer>
                    
                    </section>
                
                </form>
            
            </div>

        </div>

    </div>

</cfoutput>