<cfoutput>
	<div id="line-category-list-root">

        <div class="row">
            <div class="col-8" id="page-title">
				#pageTitle()#
            </div>
            <div class="col-4">
				<select class="form-control me-2" name="categoryId" data-bind="events: { change: change }">
					<cfloop array="#prc.categories#" item="item">
						<option data-name="#item.getName()#" value="#item.getId()#" <cfif item.getId() == prc.category.getId()>SELECTED</cfif>>#item.getName()#</option>
					</cfloop>
				</select>
            </div>
        </div>

		<div class="row">
			<div class="col-lg-12">
				<section class="card">
					<div class="card-body">

						<form name="line-category-grid-form" id="line-category-grid-form" method="post">
							<div class="col-12">
								#grid(
									id      = "line-category-grid",
									columns = "[
                                        { 'field':'shortId', 'title':'ID', width: '80px' },
                                        { 'field':'code', 'title':'Codice', width: '90px' },
                                        { 'field':'name', 'title':'Descrizione' },
                                        { 'field':'', 'title':'Possibili combinazioni', width: '55px'},
                                        { 'field':'', 'title':'Attributi per le combinazioni', width: '55px'},
                                        { 
                                            'field'           :'', 
                                            'title'           :'<input type=checkbox onclick=NM.util.checkAll(this) name=selectAll>', 
                                            'width'           :'40px',
                                            'headerAttributes': { 'class': 'text-center' }
                                        }
                                    ]",
									rowTemplate = "line/line-category-grid-row-tmpl"
								)#
							</div>

						</form>
					</div>
				</section>
			</div>
		</div>
	</div>

</cfoutput>
