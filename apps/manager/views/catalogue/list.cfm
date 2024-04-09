<cfoutput>

    <div class="row mb-3">
        <div class="col-lg-12">
            <section class="card">
                <header class="card-header">
                    <h2 class="card-title">Cerca nel catalogo</h2>
                </header>
                <div class="card-body">
                    <form class="horizontal-form">
                        <div class="row">
                            <div class="form-group col-4">
                                <label class="form-label">Prezzo</label>
                                <div class="custom-select-1">
                                    <select class="form-control" name="city">
                                        <option value="">-- seleziona</option>
                                        <option value="0-50">da 0 a 50 &euro;</option>
                                        <option value="51-100">da 50 a 100 &euro;</option>
                                        <option value="101-200">da 100 a 200 &euro;</option>
                                        <option value="201-99999">oltre 200 &euro;</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group col-4">
                                <label class="form-label">Categoria</label>
                                <div class="custom-select-1">
                                    <select class="form-control">
                                        <option value="">-- tutte</option>
                                        <cfloop index="item" array="#prc.categories#">
                                            <option value="#item.getId()#">#item.getName()#</option>
                                        </cfloop>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group col-4">
                                <label class="form-label">Fornitore</label>
                                <div class="custom-select-1">
                                    <select class="form-control">
                                        <option value="">-- seleziona</option>
                                        <option value="1">Dolce & Gabbana</option>
                                        <option value="1">TODS</option>
                                        <option value="1">Ristorante il Falco</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-12">
                                <a type="button" href="/manager/catalogue" class="mb-1 mt-1 me-1 btn btn-primary">Cerca articoli</a>
                            </div>
                        </div>
                    </form>
                </div>

            </section>
        </div>
    </div>
    
    <div class="row">
        <div class="col-lg-12">
            <section class="card">
                <header class="card-header">
                    <h2 class="card-title">Catalogo</h2>
                </header>
                <div class="card-body">

                    <div class="pt-4">

                        <div class="container">
                
                            <div class="row">
                                
                                <div class="col-lg-12">
                
                                    <div class="masonry-loader masonry-loader-showing">
                                        <div class="row products product-thumb-info-list">

                                            <cfloop array="#prc.list.getData()#" item="item">
                
                                                <div class="col-sm-6 col-lg-4 pb-5">
                                                    <div class="product mb-0">
                                                        <div class="product-thumb-info border-0 mb-3">
                    
                                                            <!----
                                                            <div class="product-thumb-info-badges-wrapper">
                                                                <cfif Len( item.badge )>
                                                                    <span class="badge badge-ecommerce badge-success">NEW</span>
                                                                <cfelse>
                                                                    <span class="badge badge-ecommerce">&nbsp;</span>
                                                                </cfif>
                                                            </div>
                                                            ---->
                    
                                                            <div class="addtocart-btn-wrapper">
                                                                <a href="#item.getPermalink()#" class="text-decoration-none addtocart-btn" title="Aggiungi al carrello">
                                                                    <i class="icons icon-bag"></i>
                                                                </a>
                                                            </div>
                    
                                                            <a href="#item.getPermalink()#">
                                                                <div class="product-thumb-info-image">
                                                                    <cfif !IsNull( item.getImage() )>
                                                                        <img class="img-fluid" src="#item.getImage().getPath()#" alt="#item.getImage().getAlt()#">
                                                                    <cfelse>
                                                                        <img class="img-fluid" src="/assets/1000/manager/img/no-img.png">
                                                                    </cfif>
                                                                </div>
                                                            </a>
                                                        </div>

                                                        <div class="d-flex justify-content-between">
                                                            <div>
                                                                <a href="##" class="d-block text-uppercase text-decoration-none text-color-default text-color-hover-primary line-height-1 text-0 mb-0">
                                                                    <cfloop array="#item.getCategories()#" item="category">
                                                                        #category.getName()#
                                                                    </cfloop>
                                                                </a>
                                                                <h3 class="text-3-5 font-weight-medium font-alternative text-transform-none line-height-3 mb-0 mt-1">
                                                                    <a href="#item.getPermalink()#" class="text-color-dark text-color-hover-primary">#item.getName()#</a>
                                                                </h3>
                                                            </div>
                                                        </div>
                                                        
                                                        <cfif !IsNull( item.getPrice() )>
                                                            <p class="price text-5 mb-3">
                                                                <span class="discount">#item.getPrice().getValue()#</span>
                                                                <span class="amount">#item.getPrice().getFinalPrice()#</span>
                                                            </p>
                                                        </cfif>
                                                    </div>
                                                </div>

                                            </cfloop>
                
                                        </div>
                                        <!----
                                        TODO: add pagination
                                        <div class="row mt-4">
                                            <div class="col">
                                                <ul class="pagination float-end">
                                                    <li class="page-item"><a class="page-link" href="##"><i class="fas fa-angle-left"></i></a></li>
                                                    <li class="page-item active"><a class="page-link" href="##">1</a></li>
                                                    <li class="page-item"><a class="page-link" href="##">2</a></li>
                                                    <li class="page-item"><a class="page-link" href="##">3</a></li>
                                                    <li class="page-item"><a class="page-link" href="##"><i class="fas fa-angle-right"></i></a></li>
                                                </ul>
                                            </div>
                                        </div>
                                        ----->
                                    </div>
                                </div>
                            </div>
                        </div>
                
                    </div>                    

                </div>
            </section>
        </div>
    </div>

</cfoutput>