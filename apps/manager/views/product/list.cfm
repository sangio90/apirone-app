<cfoutput>
	
	<div id="product-list-root">

        <div class="row">
            <div class="col-6">
				#pageTitle()#
            </div>
			<div class="col-6 text-end pb-3">
                #printButton( bind="click:print", size="sm", variant="default" )#
                #addButton( bind="click:new", size="sm" )#
			</div>
        </div>

		<div class="row">
			
			<div class="col-lg-12">
				<section class="card">
					<div class="card-body">
						
						<div class="row d-flex align-items-center mb-3">
							<div class="col-sm-10">
								<div class="box-search-small">
									<form
										id   ="product-grid-search-form"
										class="d-flex align-items-center justify-content-end"
										data-bind: 'events: { submit: search }'>
										
                                        <input name="str" placeholder="Cerca" class="form-control me-2" type="text">

										<select class="form-control me-2" name="statusId">
											<option value="">-- tutti gli stati</option>
											<cfloop array="#prc.statuses#" item="item">
												<option value="#item.getId()#">#item.getName()#</option>
											</cfloop>
										</select>

										<select class="form-control me-2" name="orderBy">
											<option value="product.code-asc" SELECTED>Codice [A-Z]</option>
											<option value="product.code-desc">Codice [Z-A]</option>
											<option value="product.name-asc">Descrizione [A-Z]</option>
											<option value="product.name-desc">Descrizione [Z-A]</option>
										</select>

										#searchButton( bind = "click:search" )#
									</form>
								</div>
							</div>

							<div class="col-sm-2">
								<div class="float-end">
									#deleteButton(
										bind  = "click:delete",
										size  = "sm"
									)#
								</div>

								<div class="status float-end me-3" id="status-delete"></div>
							</div>
						</div>

						<form name="product-grid-form" id="product-grid-form" method="post">
							<div class="col-12">
								#grid(
									id      = "product-grid",
									columns = "[
                                        { 'field':'shortId', 'title':'ID', width: '80px' },
                                        { 'field':'code', 'title':'Codice', width: '120px' },
                                        { 'field':'name', 'title':'Descrizione' },
                                        { 'field':'name', 'title':'Mezzi moduli', width: '55px' },
                                        { 'field':'', 'title':'Attributi', width: '55px'},
                                        { 'field':'', 'title':'Modifica', width: '55px'},
                                        { 
                                            'field'           :'', 
                                            'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                            'width'           :'40px',
                                            'headerAttributes': { 'class': 'text-center' }
                                        }

                                    ]",
									rowTemplate = "product/product-grid-row-tmpl"
								)#
							</div>
						</form>
					</div>
				</section>
			</div>
		</div>

	</div>

	#view( "product/detail-modal" )#

</cfoutput>
