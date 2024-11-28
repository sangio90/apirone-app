<cfoutput>

    <div id="product-category-list-root">

        #pageTitle()#

        <div class="row">

			<div class="col-lg-12 text-end pb-3">
				#addButton( bind = "click:new", size = "sm" )#
			</div>

            <div class="col-lg-12">

                <section class="card">
                    
                    <div class="card-body">

						<div class="row d-flex align-items-center mb-3">
							<div class="col-sm-8">
								<div class="box-search-small">
									<form
										id   ="product-category-grid-search-form"
										class="d-flex align-items-center justify-content-end"
										data-bind: 'events: { submit: search } '>
										
                                        <input name="str" placeholder="Cerca" class="form-control me-2" type="text">

                                        <select class="form-control me-2" name="statusId">
                                            <option value="">-- Seleziona</option>
                                            <cfloop array="#prc.statuses#" item="item">
                                                <option value="#item.getId()#">#item.getName()#</option>
                                            </cfloop>
                                        </select>

										<select class="form-control me-2" name="orderBy">
											<option value="">-- Ordina per</option>
										</select>

										#searchButton( bind = "click:search" )#
									</form>
								</div>
							</div>

							<div class="col-sm-4">
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
                                    { 'field':'id', 'title':'Codice', width: '150px' },
                                    { 'field':'mainText.name', 'title':'Descrizione'},
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