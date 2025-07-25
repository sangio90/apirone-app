<cfoutput>
	<div id="size-list-root">

        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
            <div class="col-4 text-end">
                #addButton( bind="click:new", size="sm" )#
            </div>
        </div>

		<div class="row">
			<div class="col-lg-12">
				<section class="card">
					<div class="card-body">
						<div class="d-flex align-items-center mb-3">
							<div class="box-search-small col-9">
								<form
									name  ="size-grid-search-form" id="size-grid-search-form"
									method="get"
									class ="row"
									data-bind="events: { submit: search }"
								>
									<div class="col-md-3">
										<input
											class      ="form-control"
											placeholder="Cerca..." id="attributes-search-input"
											name       ="str"
										>
									</div>

									<div class="col-md-4">
										<select class="form-control" name="categoryId">
											<option value="">-- tutte le categorie</option>
											<cfloop array="#prc.categories#" item="item">
												<option value="#item.getId()#">#item.getName()#</option>
											</cfloop>
										</select>
									</div>

									<div class="col-md-3">
										<select class="form-control" name="typeId">
											<option value="">-- tutti i tipi</option>
											<cfloop array="#prc.types#" item="item">
												<option value="#item.getId()#">#item.getName()#</option>
											</cfloop>
										</select>
									</div>

									<div class="col-md-2">
										#searchButton( bind = "click:search" )#
									</div>
								</form>
							</div>

							<div class="col-3 text-end">
								<div class="float-end">
									#deleteButton(
										bind  = "click:delete",
										size  = "sm"
									)#
								</div>
							</div>

						</div>

						<form name="size-grid-form" id="size-grid-form" method="post">
							#grid(
								id      = "size-grid",
								columns = "[
                                    { 'field':'shortId', 'title':'ID', width: '80px' },
                                    { 'field':'code', 'title':'Codice', width: '80px' },
                                    { 'field':'type.id', 'title':'Tipo', width: '60px' },
                                    { 'field':'mainText.name', 'title':'Descrizione'},
                                    { 'field':'categories', 'title':'Categorie'},
                                    { 'field':'fruitsCount', 'title':'Frutti', width: '80px'},
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
