<cfoutput>

    <div id="catalog-bundle-list-root">

        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
        </div>

        <div class="row">

            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

                        <div class="row d-flex align-items-center mb-3 ">

                            <div class="col-sm-10">

                                <div class="box-search-small"> 

                                    <form id="catalog-bundle-grid-search-form" 
                                        class="d-flex align-items-center justify-content-end" 
                                        data-bind:'events: { submit: search }'>

										<div class="col">
											<span>Cerca</span>
											<input class="form-control me-2" name="str">
										</div>

										<div class="col">
											<span>Categoria</span>
											<select class="form-control me-2" name="categoryId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.categories#" item="item">
													<option value="#item.getId()#">#item.getName()#</option>
												</cfloop>
											</select>
										</div>

										<div class="col">
											<span>Linea</span>
											<select class="form-control me-2" name="lineId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.lines#" item="item">
													<option value="#item.getId()#">#item.getName()#</option>
												</cfloop>
											</select>
										</div>

										<div class="col">
											<span>Modello</span>
											<select class="form-control me-2" name="modelId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.models#" item="item">
													<option value="#item.getId()#">#item.getName()# (#item.getCode()#)</option>
												</cfloop>
											</select>
										</div>
                                    
                                        <div class="align-self-end">
                                            #searchButton(bind="click:search")#
                                        </div>
                                    
                                    </form>

                                </div>
                            
                            </div>

							<div class="col-sm-12">
								<div class="float-end d-flex align-items-center">
                                    <div class="me-2 status" id="catalog-bindle-save-status"></div>
									#saveButton( bind = "click:save", size = "sm" )#
								</div>
							</div>

                        </div>
                        
                        <form name="catalog-bundle-grid-form" id="catalog-bundle-grid-form" method="post">

                            #grid( 
                                id="catalog-bundle-grid",
                                columns="[
                                    { 'field':'shortId', 'title':'ID', width: '80px'},
                                    { 'field':'createdAt', 'title':'Creato il', width: '140px' },
                                    { 'field':'category.name', 'title':'Categoria'},
                                    { 'field':'line.name', 'title':'Linea' },
                                    { 'field':'model.name', 'title':'Finitura' },
                                    { 'field':'Markup', 'title':'Markup %', width: '120px'  },
                                ]",
                                rowTemplate="catalog-bundle/catalog-bundle-grid-row-tmpl"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>

    </div>

</cfoutput>
