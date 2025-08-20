<cfoutput>

    <div id="product-category-list-root">

        <div class="row">
            <div class="col-6">
				#pageTitle()#
            </div>
			<div class="col-6 text-end pb-3">
                #addButton( bind = "click:new", size = "sm" )#
            </div>
        </div>
        
        <div class="row">

            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

						<div class="row d-flex align-items-center mb-3">
							<div class="col-sm-9">
								<div class="box-search-small">
									<form
										id   ="product-category-grid-search-form"
										class="d-flex align-items-center justify-content-end"
										data-bind: 'events: { submit: search } '>
										
										<div class="col">
											<span>Cerca</span>
											<input name="str" placeholder="Cerca" class="form-control me-2" type="text">
										</div>

										<div class="col">
											<span>Stato</span>
											<select class="form-control me-2" name="statusId">
                                                <option value="">-- tutti</option>
                                                <cfloop array="#prc.statuses#" item="item">
                                                    <option value="#item.getId()#">#item.getName()#</option>
                                                </cfloop>
                                            </select>
										</div>

										<div class="col">
											<span>Tipi</span>
											<select class="form-control me-2" name="typeId">
												<option value="">-- tutti</option>
                                                <cfloop array="#prc.types#" item="item">
    												<option value="#item.getId()#">#item.getName()#</option>
                                                </cfloop>
										    </select>
                                        </div>

										<div class="col">
											<span>Ordina per</span>
											<select class="form-control me-2" name="orderBy">
												<option value="productCategory.id-asc">ID [A-Z]</option>
												<option value="productCategory.id-desc">ID [Z-A]</option>
												<option value="productCategory.code-asc">Codice [A-Z]</option>
												<option value="productCategory.code-desc">Codice [Z-A]</option>
												<option value="text.text-asc">Descrizione [A-Z]</option>
	    										<option value="text.text-desc">Descrizione [Z-A]</option>
    										</select>
                                        </div>
                                        
                                        <div class="align-self-end">
										    #searchButton( bind = "click:search" )#
                                        </div>
									</form>
								</div>
							</div>

							<div class="col-sm-3">
								<div class="float-end">
									#deleteButton(
										bind  = "click:delete",
										size  = "sm"
									)#
								</div>
							</div>
						</div>                        

                        <form name="product-category-grid-form" id="product-category-grid-form" method="post">

                            #grid( 
                                source="rows",
                                id="product-category-grid",
                                columns="[
                                    { 'field':'id', 'title':'ID', width: '50px' },
                                    { 'field':'id', 'title':'Codice', width: '100px' },
                                    { 'field':'nameItem.name', 'title':'Nome'},
                                    { 'field':'type.name', 'title':'Tipo'},
                                    { 'field':'mode.id', 'title':'Modalità'},
                                    { 'field':'', 'title':'', width: '55px'},
                                    { 
                                        'field':'', 
                                        'title':'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                        'width':'40px',
                                        'headerAttributes': { 'class': 'text-center' }
                                    }
                                ]",
                                rowTemplate="product-category/product-category-grid-row-tmpl"
                            )#

                        </form>
                                        
                    </div>
                </section>
            </div>
        </div>

        #view( "product-category/detail-modal" )#

    </div>


</cfoutput>