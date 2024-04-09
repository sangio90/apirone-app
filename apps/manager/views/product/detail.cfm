<cfoutput>

    <div id="product-detail">


        <div class="row mb-3">
            <div class="col-lg-8">
                <h2>#prc.title#</h2>
            </div>
            <div class="col-lg-4">
                <div class="float-end">
                    <a type="button" href="/manager/product/variant" class="mt-4 me-1 btn btn-primary btn-sm">Varianti e immagini &raquo;</a>
                </div>
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
                                    <input type="text" name="code" class="form-control" maxlength="15" placeholder="" 
                                        onkeyup="this.value=this.value.toUpperCase()" 
                                    />
                                </div>
                            </div>

                            <div class="form-group row pb-3">
                                <label class="col-sm-3 control-label text-sm-end pt-2">Nome del prodotto</label>
                                <div class="col-sm-9">
                                    <input type="text" name="name" class="form-control" placeholder=""/>
                                </div>
                            </div>

                            <div class="form-group row pb-3">
                                <label class="col-sm-3 control-label text-sm-end pt-2">
                                    Azienda
                                </label>
                                <div class="col-sm-9">
                                    <select class="form-control" name="companyId" id="companyId">
                                        <option value="">-- seleziona</option>
                                        <cfloop array="#prc.companies.getData()#" index="index">
                                            <option value="#index.getId()#">#index.getName()#</option>
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
                                        <cfloop array="#prc.statusList.getData()#" index="index">
                                            <option value="#index.getId()#">#index.getName()#</option>
                                        </cfloop>
                                    </select>
                                </div>
                            </div>

                            <div class="form-group row pb-3">
                                <label class="col-sm-3 control-label text-sm-end pt-2">
                                    Tipo varianti
                                </label>
                                <div class="col-sm-9">
                                    <select class="form-control" name="variantTypeId" id="variantTypeId" onchange="ZB.product.detail.showFirstVariant()">
                                        <cfloop array="#prc.variantTypes.getData()#" index="index">
                                            <option value="#index.getId()#">#index.getName()#</option>
                                        </cfloop>
                                    </select>
                                </div>
                            </div>
                            
                            <div id="show-first-variant-note">
                                <div class="form-group row pb-3">
                                    <div class="col-sm-9 offset-md-3">Potrai caricare i prezzi nelle varianti.</div>
                                </div>
                            </div>
                            
                            <div id="show-first-variant">

                                <div class="form-group row pb-3">
                                    <label class="col-sm-3 control-label text-sm-end pt-2">Prezzo</label>
                                    <div class="col-sm-9">
                                        <div class="input-group">
                                            <input type="number" name="price" class="form-control" placeholder="" />
                                            <span class="input-group-text">
                                                <i class="fa fa-euro text-4"></i>
                                            </span>
                                        </div>
                                        <div id="price-error"></div>
                                    </div>
                                </div>
            
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

                                <div class="form-group row pb-3">
                                    <label class="col-sm-3 control-label text-sm-end pt-2">
                                        Peso
                                    </label>
                                    <div class="col-sm-9">
                                        <input type="number" name="weight" class="form-control" placeholder=""/>
                                    </div>
                                </div>
    
                                <div class="form-group row pb-3">
                                    <label class="col-sm-3 control-label text-sm-end pt-2">
                                        Quantità disponibile
                                    </label>
                                    <div class="col-sm-9">
                                        <input type="number" name="availableQuantity" class="form-control" placeholder=""/>
                                    </div>
                                </div>
    
                            </div>

                            <div class="form-group row pb-3">
                                <label class="col-sm-3 control-label text-sm-end pt-2">
                                    Quantità minima
                                </label>
                                <div class="col-sm-9">
                                    <input type="number" name="minQuantity" class="form-control" placeholder=""/>
                                </div>
                            </div>
                            
                            <div class="form-group row pb-3">
                                <label class="col-sm-3 control-label text-sm-end pt-2">
                                    Categorie <!---- <span class="required">*</span> ---->
                                </label>
                                <div class="col-sm-9">
                                    <cfloop array="#prc.categories.getData()#" item="category">
                                        <div class="checkbox-custom chekbox-primary">
                                            <input id="for-project-#category.getId()#" value="#category.getId()#" type="checkbox" name="categories" />
                                            <label for="for-project-#category.getId()#">#category.getName()#</label>
                                        </div>
                                    </cfloop>
                                    <!--- <label class="error" for="for[]"></label> ---->
                                </div>
                            </div>

                        </div>

                        <footer class="card-footer">
                            <div class="row justify-content-end">
                                <div class="col-sm-9">
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