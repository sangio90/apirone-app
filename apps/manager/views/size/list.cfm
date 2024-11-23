<cfoutput>
	<div id="size-list-root">
		#pageTitle()#

		<div class="row">
			<div class="col-lg-12 text-end pb-3">
				#addButton( bind = "click:new", size = "sm" )#
			</div>

			<div class="col-lg-12">
				<section class="card">
					<div class="card-body">
						<div class="row">
							<div class="mb-3 box-search-small col-8">
								<form
									name  ="size-grid-search-form" id="size-grid-search-form"
									method="get"
									class ="d-flex align-items-center"
									data-bind="events: { submit: search }"
								>
									<div class="col me-2">
										<input
											class      ="form-control"
											placeholder="Cerca..." id="attributes-search-input"
											name       ="str"
										>
									</div>

									<div class="col-auto me-2 col-7">
										<select class="form-control" name="categoryId">
											<option value="">-- tutte le categorie</option>
											<cfloop array="#prc.categories#" item="item">
												<option value="#item.getId()#">#item.getName()#</option>
											</cfloop>
										</select>
									</div>

									<div class="col-auto">
										#searchButton( bind = "click:search" )#
									</div>
								</form>
							</div>
						</div>

						<form name="size-grid-form" id="size-grid-form" method="post">
							#grid(
								id      = "size-grid",
								columns = "[
                                    { 'field':'shortId', 'title':'ID', width: '80px' },
                                    { 'field':'code', 'title':'Codice', width: '80px' },
                                    { 'field':'categories', 'title':'Categorie'},
                                    { 'field':'fruitsCount', 'title':'Frutti'},
                                    { 'field':'', 'title':'', width: '50px'},
                                    { 
                                        'field'           :'', 
                                        'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                        'width'           :'40px',
                                        'headerAttributes': { 'class': 'text-center' }
                                    }
                                ]",
								rowTemplate = "size/size-grid-row"
							)#
						</form>
					</div>
				</section>
			</div>
		</div>

		#view( "size/detail-modal" )#
	</div>
</cfoutput>
