<cfoutput>

	<div id="product-combinations-root">

        <div class="row">
            <div class="col-12">
				#pageTitle()#
            </div>
        </div>

		<div class="row">

			<div class="col-lg-12">
				<section class="card">
					<div class="card-body">

						<div class="row d-flex align-items-center mb-3">
							<div class="col-sm-6">
								<div class="box-search-small">
									<form
										id   ="product-combinations-search-form"
										class="d-flex align-items-center justify-content-end"
										data-bind: 'events: { submit: search }'>

                                        <input name="str" placeholder="Cerca" class="form-control me-2" type="text">

										<select class="form-control me-2" name="statusId">
											<option value="">-- tutti gli stati</option>
											<cfloop array="#prc.statuses#" item="item">
												<option value="#item.getId()#">#item.getName()#</option>
											</cfloop>
										</select>

										#searchButton( bind = "click:search" )#
									</form>
								</div>
							</div>
							<div class="col-sm-6 text-end">
								#button(icon="list", label="Calcola combinazioni", class="k-ml-2", bind = "click:calculate" )#
								#deleteButton(label="Cancella", class="k-ml-2", bind = "click:delete" )#
							</div>
						</div>

						<form name="product-combinations-form" id="product-combinations-form" method="get">
							<div class="col-12">
								#grid(
									id      = "product-combinations",
									pageSizes = "false",
									columns = "[
                                        { 'field':'shortId', 'title':'ID', width: '80px' },
                                        { 'field':'name', 'title':'Descrizione' },
                                        { 'field':'', 'title':'Immagini', width: '55px'},
                                        {
                                            'field'           :'',
                                            'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>',
                                            'width'           :'40px',
                                            'headerAttributes': { 'class': 'text-center' }
                                        }

                                    ]",
									rowTemplate = "product/product-combinations-row-tmpl"
								)#
							</div>
						</form>
					</div>
				</section>
			</div>
		</div>

	</div>

	#view( view="file/list-modal" )#

</cfoutput>
