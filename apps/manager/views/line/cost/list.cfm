<cfoutput>
	
	<div id="line-cost-list-root">

        <div class="row">
            <div class="col-6">
				#pageTitle()#
            </div>
        </div>

		<div class="row">
			
			<div class="col-lg-12">
				<section class="card">
					<div class="card-body">
						
						<div class="row d-flex align-items-center mb-3">
							<div class="col-sm-12">
								<div class="box-search-small">
									<form
										method = "post"
										id     = "line-cost-add-form"
										class  = "d-flex align-items-center justify-content-end"
										action = "/manager/lines/costs/add">
										<!---
										data-bind: 'events: { submit: search }'>
										---->

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
											<span>Finitura</span>
											<select class="form-control me-2" name="finishId">
												<option value="">-- tutte</option>
												<cfloop array="#prc.finishes#" item="item">
													<option value="#item.getId()#">#item.getName()# (#item.getCode()#)</option>
												</cfloop>
											</select>
										</div>

										<div class="col col-md-2 me-2" style="width: 150px;">
											<span>Costo</span>
											<input class="form-control me-2" name="cost" style="width: 100px;">
										</div>

										<div class="align-self-end d-flex">
											#addButton( bind = "click:add", class="me-1" )#
										</div>
									</form>
								</div>
							</div>

						</div>

						<form name="line-cost-grid-form" id="line-cost-grid-form" method="post">

							<div class="text-end mb-2">
								#saveButton( bind="click:save", size="sm" )#
							</div>

							<div class="col-12">
								#grid(
									id      = "line-cost-grid",
									columns = "[
                                        { 'field':'shortId', 'title':'ID', width: '80px' },
                                        { 'field':'category.id', 'title':'Categoria' },
                                        { 'field':'line.name', 'title':'Linea' },
                                        { 'field':'finish.name', 'title':'Finitura'},
                                        { 'field':'prices', 'title':'Costo', 'width': '150px' }
                                    ]",
									rowTemplate = "line/line-cost-grid-row-tmpl"
								)#
							</div>
						</form>
					</div>
				</section>
			</div>
		</div>

	</div>

	#view( "price/list-modal" )#

</cfoutput>
