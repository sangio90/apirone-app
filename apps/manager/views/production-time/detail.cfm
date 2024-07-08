<cfoutput>

    <div id="product-detail">

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
                            
                            <div class="form-group row pb-3">
                                <label class="col-sm-3 control-label text-sm-end pt-2">Codice</label>
                                <div class="col-sm-9">
                                    <input type="text" name="code" class="form-control" maxlength="15" placeholder="" value="001"
                                        onkeyup="this.value=this.value.toUpperCase()" 
                                    />
                                </div>
                            </div>

                            <div class="form-group row pb-3">
                                <label class="col-sm-3 control-label text-sm-end pt-2">Unità di misura</label>
                                <div class="col-sm-9">
                                    <select class="form-control" name="companyId" id="companyId">
                                        <option value="">-- seleziona</option>
                                        <cfloop array="#prc.units#" item="item">
                                            <option value="#item.id#" SELECTED>#item.name#</option>
                                        </cfloop>
                                    </select>
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

                            <!----
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
                                                <i class="fa fa-euro text-4"></i>
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
                                                <i class="fa fa-euro text-4"></i>
                                            </span>
                                        </div>
                                        <div id="price-error"></div>
                                    </div>
                                </div>                                
            
                            </cfloop>
                            ---->

                        </div>

                        <footer class="card-footer">
                            <div class="row justify-content-end">
                                <div class="col-sm-9 my-2">
                                    <button class="btn btn-primary">Salva &raquo;</button>
                                    <input type="hidden" name="id" value="" />
                                </div>
                            </div>
                        </footer>
                    
                    </section>
                
                </form>
            
            </div>

        </div>

    </div>

</cfoutput>