<cfoutput>
	<div id="article-list-root">

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
							<div class="col-sm-10">
								<div class="box-search-small">
									<form
										id   ="article-grid-search-form"
										class="d-flex align-items-center justify-content-end"
										data-bind: 'events: { submit: search }'>
										
										<div class="col">
											<span>Cerca</span>
											<input name="str" placeholder="Cerca" class="form-control me-2" type="text">
										</div>

										<div class="col">
											<span>Tipo</span>
											<select class="form-control me-2" name="typeId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.types#" item="thisType">
													<option value="#thisType.getId()#">#thisType.getName()#</option>
												</cfloop>
											</select>
										</div>

										<div class="col">
											<span>Status</span>
											<select class="form-control me-2" name="statusId">
												<option value="">-- tutti</option>
												<cfloop array="#prc.statuses#" item="item">
													<option value="#item.getId()#">#item.getName()#</option>
												</cfloop>
											</select>
										</div>

										<div class="col">
											<span>Ordina per</span>
											<select class="form-control me-2" name="orderBy">
												<option value="article.code-asc" SELECTED>Codice [A-Z]</option>
												<option value="article.code-desc">Codice [Z-A]</option>
												<option value="article.externalId-asc">Codice esterno [A-Z]</option>
												<option value="article.externalId-desc">Codice esterno [Z-A]</option>
											</select>
										</div>

										<div class="align-self-end">
											#searchButton( bind = "click:search" )#
										</div>
									</form>
								</div>
							</div>

							<div class="col-sm-2">
								<div class="float-end">
									#deleteButton( bind  = "click:delete", size = "sm" )#
								</div>

								<div class="status float-end me-3" id="status-delete"></div>
							</div>
						</div>

						<form name="article-grid-form" id="article-grid-form" method="post">
							<div class="col-12">
								#grid(
									id      = "article-grid",
									columns = "[
                                        { 'field':'shortId', 'title':'ID', width: '80px' },
                                        { 'field':'code', 'title':'Codice', width: '100px' },
                                        { 'field':'externalId', 'title':'Codice esterno', width: '120px' },
                                        { 'field':'nameItem.name', 'title':'Nome' },
                                        { 'field':'price.amount', 'title':'Prezzo', width: '90px' },
                                        { 'field':'type.name', 'title':'Tipo', width: '110px'  },
                                        { 'field':'', 'title':'Modifica', width: '55px'},
                                        { 
                                            'field'           :'', 
                                            'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                            'width'           :'40px',
                                            'headerAttributes': { 'class': 'text-center' }
                                        }
                                    ]",
									rowTemplate = "article/article-grid-row-tmpl"
								)#
							</div>
						</form>
					</div>
				</section>
			</div>
		</div>
	</div>

	#view( "article/detail-modal" )#

</cfoutput>
